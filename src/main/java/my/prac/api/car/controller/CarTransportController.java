package my.prac.api.car.controller;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.service.CarTransportService;

@Controller
@RequestMapping("/transport")
public class CarTransportController {

    @Resource(name = "core.car.CarTransportService")
    private CarTransportService carTransportService;

    @GetMapping("/list")
    public String list(@RequestParam(required = false) String dateFrom,
                       @RequestParam(required = false) String dateTo,
                       @RequestParam(required = false) String driverName,
                       @RequestParam(required = false) String company,
                       Model model) {

        // 날짜 기본값: 당월 1일 ~ 오늘
        if (dateFrom == null && dateTo == null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Calendar cal = Calendar.getInstance();
            cal.set(Calendar.DAY_OF_MONTH, 1);
            dateFrom = sdf.format(cal.getTime());
            dateTo   = sdf.format(new Date());
        }

        Map<String, Object> params = new HashMap<>();
        params.put("dateFrom",   dateFrom);
        params.put("dateTo",     dateTo);
        params.put("driverName", driverName);
        params.put("company",    company);

        List<CarTransportDto> list = carTransportService.getList(params);

        long totalSupply  = list.stream().mapToLong(CarTransportDto::getSupplyPrice).sum();
        long totalCompany = list.stream().mapToLong(CarTransportDto::getCompanyPrice).sum();

        model.addAttribute("list",         list);
        model.addAttribute("totalSupply",  totalSupply);
        model.addAttribute("totalCompany", totalCompany);
        model.addAttribute("dateFrom",     dateFrom);
        model.addAttribute("dateTo",       dateTo);
        model.addAttribute("driverName",   driverName);
        model.addAttribute("company",      company);
        model.addAttribute("driverNames",  carTransportService.getDistinctDriverNames());
        model.addAttribute("companies",    carTransportService.getDistinctCompanies());
        return "car/transport_list";
    }

    @GetMapping("/write")
    public String writeForm(Model model) {
        return "car/transport_write";
    }

    @PostMapping("/write")
    public String write(CarTransportDto dto) {
        carTransportService.insert(dto);
        return "redirect:/transport/list";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable int id, Model model) {
        model.addAttribute("dto", carTransportService.getDetail(id));
        return "car/transport_edit";
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable int id, CarTransportDto dto) {
        dto.setId(id);
        carTransportService.update(dto);
        return "redirect:/transport/list";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable int id) {
        carTransportService.softDelete(id);
        return "redirect:/transport/list";
    }

    /** 일괄 입력 폼 */
    @GetMapping("/bulk")
    public String bulkForm() {
        return "car/transport_bulk";
    }

    /** 일괄 저장 */
    @PostMapping("/bulk")
    public String bulkSave(
            @RequestParam(value = "transportDate[]", required = false) List<String> dates,
            @RequestParam(value = "driverName[]",    required = false) List<String> driverNames,
            @RequestParam(value = "company[]",       required = false) List<String> companies,
            @RequestParam(value = "loadingPoint[]",  required = false) List<String> loadingPoints,
            @RequestParam(value = "unloadingPoint[]",required = false) List<String> unloadingPoints,
            @RequestParam(value = "carModel[]",      required = false) List<String> carModels,
            @RequestParam(value = "vehicleNo[]",     required = false) List<String> vehicleNos,
            @RequestParam(value = "supplyPrice[]",   required = false) List<String> supplyPrices,
            @RequestParam(value = "companyPrice[]",  required = false) List<String> companyPrices) {

        if (dates == null || dates.isEmpty()) {
            return "redirect:/transport/bulk";
        }

        List<CarTransportDto> batch = new ArrayList<>();
        for (int i = 0; i < dates.size(); i++) {
            String date       = getOrEmpty(dates, i);
            String driverName = getOrEmpty(driverNames, i);
            String company    = getOrEmpty(companies, i);
            String loading    = getOrEmpty(loadingPoints, i);
            String unloading  = getOrEmpty(unloadingPoints, i);

            // 필수값 없으면 해당 행 스킵
            if (date.isEmpty() || driverName.isEmpty() || company.isEmpty()
                    || loading.isEmpty() || unloading.isEmpty()) {
                continue;
            }

            CarTransportDto dto = new CarTransportDto();
            dto.setTransportDate(date);
            dto.setDriverName(driverName);
            dto.setCompany(company);
            dto.setLoadingPoint(loading);
            dto.setUnloadingPoint(unloading);
            dto.setCarModel(getOrEmpty(carModels, i));
            dto.setVehicleNo(getOrEmpty(vehicleNos, i));
            dto.setSupplyPrice(parseLong(getOrEmpty(supplyPrices, i)));
            dto.setCompanyPrice(parseLong(getOrEmpty(companyPrices, i)));
            batch.add(dto);
        }

        if (!batch.isEmpty()) {
            carTransportService.insertBatch(batch);
        }

        return "redirect:/transport/bulk?saved=" + batch.size();
    }

    private String getOrEmpty(List<String> list, int idx) {
        if (list == null || idx >= list.size()) return "";
        String v = list.get(idx);
        return v == null ? "" : v.trim();
    }

    private long parseLong(String val) {
        try { return Long.parseLong(val.replaceAll("[^0-9]", "")); }
        catch (Exception e) { return 0L; }
    }
}
