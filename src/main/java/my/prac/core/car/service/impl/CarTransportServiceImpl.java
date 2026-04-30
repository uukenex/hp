package my.prac.core.car.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import my.prac.core.car.dao.CarTransportDAO;
import my.prac.core.car.dto.CarTransportDto;
import my.prac.core.car.dto.CarTransportFileDto;
import my.prac.core.car.service.CarTransportService;

@Service("core.car.CarTransportService")
public class CarTransportServiceImpl implements CarTransportService {

    @Resource(name = "core.car.CarTransportDAO")
    private CarTransportDAO carTransportDAO;

    @Override
    public List<CarTransportDto> getList(Map<String, Object> params) {
        return carTransportDAO.getList(params);
    }

    @Override
    public CarTransportDto getDetail(int id) {
        return carTransportDAO.getDetail(id);
    }

    @Override
    public void insert(CarTransportDto dto) {
        carTransportDAO.insert(dto);
    }

    @Override
    public void insertBatch(List<CarTransportDto> list) {
        for (CarTransportDto dto : list) {
            carTransportDAO.insert(dto);
        }
    }

    @Override
    public void update(CarTransportDto dto) {
        carTransportDAO.update(dto);
    }

    @Override
    public void delete(int id) {
        carTransportDAO.delete(id);
    }

    @Override
    public List<CarTransportFileDto> getFileList(int transportId) {
        return carTransportDAO.getFileList(transportId);
    }

    @Override
    public CarTransportFileDto getFileDetail(int fileId) {
        return carTransportDAO.getFileDetail(fileId);
    }

    @Override
    public void insertFile(CarTransportFileDto dto) {
        carTransportDAO.insertFile(dto);
    }

    @Override
    public void deleteFile(int fileId) {
        carTransportDAO.deleteFile(fileId);
    }

    @Override
    public void deleteFilesByTransportId(int transportId) {
        carTransportDAO.deleteFilesByTransportId(transportId);
    }
}
