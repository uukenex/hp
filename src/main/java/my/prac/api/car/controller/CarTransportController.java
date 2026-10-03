package my.prac.api.car.controller;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.service.CarTransportService;

@Controller
@RequestMapping("/transport")
public class CarTransportController {

    @Resource(name = "core.car.CarTransportService")
    private CarTransportService carTransportService;

    /** 메인 페이지 (SPA 셸) - 데이터는 /transport/api/* 로 로드 */
    @GetMapping("/list")
    public String list() {
        return "car/transport_list";
    }

    /** 월별 조회. month=YYYY-MM (없으면 당월) */
    @GetMapping("/api/list")
    @ResponseBody
    public Map<String, Object> apiList(@RequestParam(required = false) String month) {
        SimpleDateFormat ym = new SimpleDateFormat("yyyy-MM");
        if (month == null || !month.matches("\\d{4}-\\d{2}")) {
            month = ym.format(Calendar.getInstance().getTime());
        }
        int year = Integer.parseInt(month.substring(0, 4));
        int mon  = Integer.parseInt(month.substring(5, 7));
        Calendar cal = Calendar.getInstance();
        cal.clear();
        cal.set(year, mon - 1, 1);
        int last = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

        Map<String, Object> params = new HashMap<>();
        params.put("dateFrom", month + "-01");
        params.put("dateTo",   month + "-" + (last < 10 ? "0" + last : String.valueOf(last)));

        Map<String, Object> res = new HashMap<>();
        res.put("month",       month);
        res.put("list",        carTransportService.getList(params));
        res.put("driverNames", carTransportService.getDistinctDriverNames());
        res.put("companies",   carTransportService.getDistinctCompanies());
        return res;
    }

    /** 자동저장: id가 0이면 신규 등록, 아니면 수정. 저장된 id를 반환 */
    @PostMapping("/api/save")
    @ResponseBody
    public Map<String, Object> apiSave(@RequestBody CarTransportDto dto) {
        if (dto.getId() > 0) {
            carTransportService.update(dto);
        } else {
            carTransportService.insert(dto);
        }
        Map<String, Object> res = new HashMap<>();
        res.put("id", dto.getId());
        return res;
    }

    /** 소프트 삭제 */
    @PostMapping("/api/delete/{id}")
    @ResponseBody
    public Map<String, Object> apiDelete(@PathVariable int id) {
        carTransportService.softDelete(id);
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true);
        return res;
    }
}
