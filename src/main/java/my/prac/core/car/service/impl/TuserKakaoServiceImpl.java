package my.prac.core.car.service.impl;

import java.util.UUID;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import my.prac.core.car.dao.TuserKakaoDAO;
import my.prac.core.car.dto.TuserKakaoDto;
import my.prac.core.car.service.TuserKakaoService;

@Service("core.car.TuserKakaoService")
public class TuserKakaoServiceImpl implements TuserKakaoService {

    @Resource(name = "core.car.TuserKakaoDAO")
    private TuserKakaoDAO tuserKakaoDAO;

    @Override
    public TuserKakaoDto saveOrUpdateLogin(TuserKakaoDto dto) {
        String token = UUID.randomUUID().toString();
        dto.setAutoLoginToken(token);

        TuserKakaoDto existing = tuserKakaoDAO.findByKakaoId(dto.getKakaoId());
        if (existing == null) {
            tuserKakaoDAO.insert(dto);
        } else {
            tuserKakaoDAO.updateLogin(dto);
        }
        return dto;
    }

    @Override
    public TuserKakaoDto findByToken(String token) {
        return tuserKakaoDAO.findByToken(token);
    }
}
