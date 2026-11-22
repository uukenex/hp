-- 카카오 닉네임의 특수문자/이모지가 ?? 로 깨지지 않도록 유니코드(NVARCHAR2) 컬럼으로 변경
-- DB 기본 문자셋 KO16MSWIN949 에 없는 문자도 저장됨. 저장 시 매퍼에서 NStringTypeHandler(setNString) 사용
-- (2026-11-22 운영 DB 적용 완료)
ALTER TABLE TCAR_USER_KAKAO MODIFY NICKNAME NVARCHAR2(100);
