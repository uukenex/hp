package my.prac.core.car.service.impl;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import my.prac.core.car.dao.TuserKakaoDAO;
import my.prac.core.car.dto.TuserKakaoDto;
import my.prac.core.car.service.TuserKakaoService;

@Service
public class TuserKakaoServiceImpl implements TuserKakaoService {

    @Autowired
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
