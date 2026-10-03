package my.prac.api.car.controller;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import java.util.List;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.dto.CarTransportHistoryDto;
import my.prac.core.car.dto.CarUserDto;
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
    public Map<String, Object> apiSave(@RequestBody CarTransportDto dto, HttpSession session) {
        String by = currentUser(session);
        if (dto.getId() > 0) {
            CarTransportDto before = carTransportService.getDetail(dto.getId());
            carTransportService.update(dto);
            String diff = diff(before, dto);
            if (diff.length() > 0) {
                writeHistory(dto.getId(), "UPDATE", dto, diff, by);
            }
        } else {
            carTransportService.insert(dto);
            writeHistory(dto.getId(), "INSERT", dto, describe(dto), by);
        }
        Map<String, Object> res = new HashMap<>();
        res.put("id", dto.getId());
        return res;
    }

    /** 소프트 삭제 (삭제 직전 값을 이력에 남김) */
    @PostMapping("/api/delete/{id}")
    @ResponseBody
    public Map<String, Object> apiDelete(@PathVariable int id, HttpSession session) {
        CarTransportDto before = carTransportService.getDetail(id);
        carTransportService.softDelete(id);
        if (before != null) {
            writeHistory(id, "DELETE", before, describe(before), currentUser(session));
        }
        Map<String, Object> res = new HashMap<>();
        res.put("ok", true);
        return res;
    }

    /** 변경 이력 (최근 300건) */
    @GetMapping("/api/history")
    @ResponseBody
    public List<CarTransportHistoryDto> apiHistory() {
        return carTransportService.getHistory(300);
    }

    // ===== 이력 헬퍼 =====

    private static final String[] FIELD_LABELS = {
        "날짜", "기사님", "회사", "상차", "하차", "차종", "차대번호", "공급가", "회사공급가",
        "상차폰,사업자", "사진,지급", "입금", "계산서발행", "내역서", "비고"
    };

    private String[] values(CarTransportDto d) {
        return new String[] {
            n(d.getTransportDate()), n(d.getDriverName()), n(d.getCompany()),
            n(d.getLoadingPoint()), n(d.getUnloadingPoint()), n(d.getCarModel()), n(d.getVehicleNo()),
            String.valueOf(d.getSupplyPrice()), String.valueOf(d.getCompanyPrice()),
            n(d.getLoadingPhone()), n(d.getPhotoPayment()), n(d.getDeposit()),
            n(d.getInvoiceIssued()), n(d.getStatementDoc()), n(d.getRemark())
        };
    }

    private String n(String s) { return s == null ? "" : s.trim(); }

    /** 변경된 항목만 "라벨: 이전 → 이후" 형태로 */
    private String diff(CarTransportDto before, CarTransportDto after) {
        if (before == null) return describe(after);
        String[] b = values(before), a = values(after);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < a.length; i++) {
            if (!b[i].equals(a[i])) {
                if (sb.length() > 0) sb.append('\n');
                sb.append(FIELD_LABELS[i]).append(": ")
                  .append(b[i].isEmpty() ? "(빈값)" : b[i]).append(" → ")
                  .append(a[i].isEmpty() ? "(빈값)" : a[i]);
            }
        }
        return sb.toString();
    }

    /** 값이 있는 항목 전체 */
    private String describe(CarTransportDto d) {
        String[] v = values(d);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < v.length; i++) {
            if (v[i].isEmpty() || "0".equals(v[i])) continue;
            if (sb.length() > 0) sb.append('\n');
            sb.append(FIELD_LABELS[i]).append(": ").append(v[i]);
        }
        return sb.toString();
    }

    private void writeHistory(int id, String action, CarTransportDto d, String detail, String by) {
        try {
            CarTransportHistoryDto h = new CarTransportHistoryDto();
            h.setTransportId(id);
            h.setAction(action);
            h.setRowLabel(cut(n(d.getTransportDate()) + " / " + n(d.getDriverName()) + " / " + n(d.getCompany())
                    + " / " + n(d.getLoadingPoint()) + " → " + n(d.getUnloadingPoint()), 450));
            h.setDetail(cut(detail, 3900));
            h.setChangedBy(by);
            carTransportService.insertHistory(h);
        } catch (Exception e) {
            // 이력 기록 실패가 저장 자체를 막지 않도록 함
            e.printStackTrace();
        }
    }

    private String cut(String s, int max) {
        return s != null && s.length() > max ? s.substring(0, max) : s;
    }

    private String currentUser(HttpSession session) {
        Object u = session.getAttribute("carUser");
        if (u instanceof CarUserDto) {
            String nick = ((CarUserDto) u).getNickname();
            return nick == null ? "" : nick;
        }
        return "";
    }
}
