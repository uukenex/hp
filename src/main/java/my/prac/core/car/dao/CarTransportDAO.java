package my.prac.core.car.dao;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Repository;

import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.dto.CarTransportFileDto;

@Repository("core.car.CarTransportDAO")
public interface CarTransportDAO {
    List<CarTransportDto>     getList(Map<String, Object> params);
    CarTransportDto           getDetail(int id);
    int                       insert(CarTransportDto dto);
    int                       update(CarTransportDto dto);
    int                       delete(int id);

    // 장표(파일첨부) 관련
    List<CarTransportFileDto> getFileList(int transportId);
    CarTransportFileDto       getFileDetail(int fileId);
    int                       insertFile(CarTransportFileDto dto);
    int                       deleteFile(int fileId);
    int                       deleteFilesByTransportId(int transportId);
}
