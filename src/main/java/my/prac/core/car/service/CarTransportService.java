package my.prac.core.car.service;

import java.util.List;
import java.util.Map;

import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.dto.CarTransportFileDto;
import my.prac.core.car.dto.CarTransportHistoryDto;

public interface CarTransportService {
    List<CarTransportDto>     getList(Map<String, Object> params);
    CarTransportDto           getDetail(int id);
    List<String>              getDistinctDriverNames(String ownerId);
    List<String>              getDistinctCompanies(String ownerId);
    void                      insert(CarTransportDto dto);
    void                      insertBatch(List<CarTransportDto> list);
    void                      update(CarTransportDto dto);
    void                      softDelete(int id);
    List<String>              getMonths(String ownerId);

    // 변경 이력
    void                      insertHistory(CarTransportHistoryDto dto);
    List<CarTransportHistoryDto> getHistory(int limit, String ownerId);

    // 장표(파일첨부) 관련
    List<CarTransportFileDto> getFileList(int transportId);
    CarTransportFileDto       getFileDetail(int fileId);
    void                      insertFile(CarTransportFileDto dto);
    void                      deleteFile(int fileId);
    void                      deleteFilesByTransportId(int transportId);
}
