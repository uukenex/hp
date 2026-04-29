package my.prac.api.car.controller;

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
        carTransportService.delete(id);
        return "redirect:/transport/list";
    }
}
