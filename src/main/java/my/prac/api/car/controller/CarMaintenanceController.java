package my.prac.api.car.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import my.prac.core.car.dto.CarMaintenanceDto;
import my.prac.core.car.dto.CarUserDto;
import my.prac.core.car.service.CarMaintenanceService;

@Controller
@RequestMapping("/car/board")
public class CarMaintenanceController {

    @Autowired
    @Lazy
    private CarMaintenanceService carMaintenanceService;

    @GetMapping("/list")
    public String list(HttpSession session, Model model) {
        CarUserDto carUser = (CarUserDto) session.getAttribute("carUser");
        List<CarMaintenanceDto> list = carMaintenanceService.getList(carUser.getKakaoId());
        model.addAttribute("list", list);
        model.addAttribute("carUser", carUser);
        return "car/board_list";
    }

    @GetMapping("/write")
    public String writeForm(HttpSession session, Model model) {
        CarUserDto carUser = (CarUserDto) session.getAttribute("carUser");
        model.addAttribute("carUser", carUser);
        return "car/board_write";
    }

    @PostMapping("/write")
    public String write(CarMaintenanceDto dto, HttpSession session) {
        CarUserDto carUser = (CarUserDto) session.getAttribute("carUser");
        dto.setKakaoId(carUser.getKakaoId());
        dto.setKakaoNickname(carUser.getNickname());
        carMaintenanceService.insert(dto);
        return "redirect:/car/board/list";
    }

    @GetMapping("/detail/{id}")
    public String detail(@PathVariable int id, HttpSession session, Model model) {
        CarUserDto carUser = (CarUserDto) session.getAttribute("carUser");
        CarMaintenanceDto dto = carMaintenanceService.getDetail(id);
        model.addAttribute("dto", dto);
        model.addAttribute("carUser", carUser);
        return "car/board_detail";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable int id, HttpSession session, Model model) {
        CarUserDto carUser = (CarUserDto) session.getAttribute("carUser");
        CarMaintenanceDto dto = carMaintenanceService.getDetail(id);
        model.addAttribute("dto", dto);
        model.addAttribute("carUser", carUser);
        return "car/board_edit";
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable int id, CarMaintenanceDto dto) {
        dto.setId(id);
        carMaintenanceService.update(dto);
        return "redirect:/car/board/detail/" + id;
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable int id) {
        carMaintenanceService.delete(id);
        return "redirect:/car/board/list";
    }
}
