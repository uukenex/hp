package my.prac.core.car.push;

import java.io.ByteArrayOutputStream;
import java.math.BigInteger;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.AlgorithmParameters;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.Signature;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECGenParameterSpec;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;
import java.security.spec.ECPublicKeySpec;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Arrays;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.KeyAgreement;
import javax.crypto.Mac;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Web Push 암호화(RFC 8291, aes128gcm) 및 VAPID(RFC 8292) 서명.
 * 외부 라이브러리 없이 JDK(SunEC) 만으로 구현.
 */
public final class WebPushCrypto {

    private static final SecureRandom RND = new SecureRandom();
    private static final ECParameterSpec P256;

    static {
        try {
            AlgorithmParameters ap = AlgorithmParameters.getInstance("EC");
            ap.init(new ECGenParameterSpec("secp256r1"));
            P256 = ap.getParameterSpec(ECParameterSpec.class);
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private WebPushCrypto() {}

    // ===== 키 =====

    /** [0]=PKCS8 개인키(Base64), [1]=공개키(65byte uncompressed, base64url) */
    public static String[] generateVapidKeys() throws Exception {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("EC");
        kpg.initialize(new ECGenParameterSpec("secp256r1"));
        KeyPair kp = kpg.generateKeyPair();
        return new String[] {
            Base64.getEncoder().encodeToString(kp.getPrivate().getEncoded()),
            b64url(encodePoint((ECPublicKey) kp.getPublic()))
        };
    }

    static byte[] encodePoint(ECPublicKey k) {
        byte[] out = new byte[65];
        out[0] = 4;
        System.arraycopy(fixed32(k.getW().getAffineX()), 0, out, 1, 32);
        System.arraycopy(fixed32(k.getW().getAffineY()), 0, out, 33, 32);
        return out;
    }

    static PublicKey decodePoint(byte[] p) throws Exception {
        if (p.length != 65 || p[0] != 4) throw new IllegalArgumentException("invalid P-256 public key");
        BigInteger x = new BigInteger(1, Arrays.copyOfRange(p, 1, 33));
        BigInteger y = new BigInteger(1, Arrays.copyOfRange(p, 33, 65));
        return KeyFactory.getInstance("EC").generatePublic(new ECPublicKeySpec(new ECPoint(x, y), P256));
    }

    private static byte[] fixed32(BigInteger v) {
        byte[] b = v.toByteArray();
        byte[] out = new byte[32];
        if (b.length > 32) System.arraycopy(b, b.length - 32, out, 0, 32);
        else System.arraycopy(b, 0, out, 32 - b.length, b.length);
        return out;
    }

    // ===== 페이로드 암호화 (RFC 8291) =====

    public static byte[] encrypt(byte[] payload, byte[] uaPublic, byte[] authSecret) throws Exception {
        KeyPairGenerator kpg = KeyPairGenerator.getInstance("EC");
        kpg.initialize(new ECGenParameterSpec("secp256r1"));
        KeyPair as = kpg.generateKeyPair();
        byte[] salt = new byte[16];
        RND.nextBytes(salt);
        return encrypt(payload, uaPublic, authSecret, as, salt);
    }

    /** 테스트용으로 임시키/salt 주입 가능 */
    static byte[] encrypt(byte[] payload, byte[] uaPublic, byte[] authSecret, KeyPair as, byte[] salt) throws Exception {
        byte[] asPublic = encodePoint((ECPublicKey) as.getPublic());

        KeyAgreement ka = KeyAgreement.getInstance("ECDH");
        ka.init(as.getPrivate());
        ka.doPhase(decodePoint(uaPublic), true);
        byte[] ecdh = ka.generateSecret();

        byte[] prkKey = hmac(authSecret, ecdh);
        byte[] keyInfo = concat("WebPush: info\0".getBytes(StandardCharsets.US_ASCII), uaPublic, asPublic);
        byte[] ikm = hmac(prkKey, concat(keyInfo, new byte[] { 1 }));
        byte[] prk = hmac(salt, ikm);
        byte[] cek = Arrays.copyOf(hmac(prk, concat("Content-Encoding: aes128gcm\0".getBytes(StandardCharsets.US_ASCII), new byte[] { 1 })), 16);
        byte[] nonce = Arrays.copyOf(hmac(prk, concat("Content-Encoding: nonce\0".getBytes(StandardCharsets.US_ASCII), new byte[] { 1 })), 12);

        Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
        c.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(cek, "AES"), new GCMParameterSpec(128, nonce));
        byte[] cipher = c.doFinal(concat(payload, new byte[] { 2 }));   // 0x02 = 마지막 레코드 구분자

        ByteArrayOutputStream out = new ByteArrayOutputStream();
        out.write(salt, 0, salt.length);
        out.write(new byte[] { 0, 0, 0x10, 0 }, 0, 4);      // record size 4096
        out.write(asPublic.length);
        out.write(asPublic, 0, asPublic.length);
        out.write(cipher, 0, cipher.length);
        return out.toByteArray();
    }

    /** 수신측 복호화 (단위 테스트용) */
    static byte[] decrypt(byte[] body, PrivateKey uaPrivate, byte[] uaPublic, byte[] authSecret) throws Exception {
        byte[] salt = Arrays.copyOfRange(body, 0, 16);
        int idlen = body[20] & 0xff;
        byte[] asPublic = Arrays.copyOfRange(body, 21, 21 + idlen);
        byte[] cipher = Arrays.copyOfRange(body, 21 + idlen, body.length);

        KeyAgreement ka = KeyAgreement.getInstance("ECDH");
        ka.init(uaPrivate);
        ka.doPhase(decodePoint(asPublic), true);
        byte[] ecdh = ka.generateSecret();

        byte[] prkKey = hmac(authSecret, ecdh);
        byte[] keyInfo = concat("WebPush: info\0".getBytes(StandardCharsets.US_ASCII), uaPublic, asPublic);
        byte[] ikm = hmac(prkKey, concat(keyInfo, new byte[] { 1 }));
        byte[] prk = hmac(salt, ikm);
        byte[] cek = Arrays.copyOf(hmac(prk, concat("Content-Encoding: aes128gcm\0".getBytes(StandardCharsets.US_ASCII), new byte[] { 1 })), 16);
        byte[] nonce = Arrays.copyOf(hmac(prk, concat("Content-Encoding: nonce\0".getBytes(StandardCharsets.US_ASCII), new byte[] { 1 })), 12);

        Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
        c.init(Cipher.DECRYPT_MODE, new SecretKeySpec(cek, "AES"), new GCMParameterSpec(128, nonce));
        byte[] plain = c.doFinal(cipher);
        int end = plain.length - 1;
        while (end >= 0 && plain[end] == 0) end--;       // 패딩(0) 제거 후 0x02 구분자 제거
        return Arrays.copyOf(plain, end);
    }

    // ===== VAPID (RFC 8292) =====

    public static String vapidAuthHeader(String endpoint, String subject, String privatePkcs8B64, String publicB64Url) throws Exception {
        URI u = URI.create(endpoint);
        String aud = u.getScheme() + "://" + u.getHost() + (u.getPort() > 0 ? ":" + u.getPort() : "");
        long exp = System.currentTimeMillis() / 1000 + 12 * 3600;
        String header = b64url("{\"typ\":\"JWT\",\"alg\":\"ES256\"}".getBytes(StandardCharsets.UTF_8));
        String claims = b64url(("{\"aud\":\"" + aud + "\",\"exp\":" + exp + ",\"sub\":\"" + subject + "\"}").getBytes(StandardCharsets.UTF_8));
        String input = header + "." + claims;

        PrivateKey pk = KeyFactory.getInstance("EC").generatePrivate(new PKCS8EncodedKeySpec(Base64.getDecoder().decode(privatePkcs8B64)));
        Signature sig = Signature.getInstance("SHA256withECDSA");
        sig.initSign(pk);
        sig.update(input.getBytes(StandardCharsets.US_ASCII));
        String jwt = input + "." + b64url(derToRaw(sig.sign()));
        return "vapid t=" + jwt + ", k=" + publicB64Url;
    }

    /** DER(ECDSA) → JOSE raw (r||s, 64byte) */
    static byte[] derToRaw(byte[] der) {
        int pos = 2;
        if ((der[1] & 0x80) != 0) pos = 2 + (der[1] & 0x7f);
        int rLen = der[pos + 1] & 0xff;
        byte[] r = Arrays.copyOfRange(der, pos + 2, pos + 2 + rLen);
        pos = pos + 2 + rLen;
        int sLen = der[pos + 1] & 0xff;
        byte[] s = Arrays.copyOfRange(der, pos + 2, pos + 2 + sLen);
        byte[] out = new byte[64];
        copyRight(r, out, 0);
        copyRight(s, out, 32);
        return out;
    }

    private static void copyRight(byte[] src, byte[] dst, int off) {
        int start = Math.max(0, src.length - 32);
        int len = src.length - start;
        System.arraycopy(src, start, dst, off + 32 - len, len);
    }

    // ===== 유틸 =====

    public static String b64url(byte[] b) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }

    public static byte[] b64urlDecode(String s) {
        return Base64.getUrlDecoder().decode(s);
    }

    private static byte[] hmac(byte[] key, byte[] data) throws Exception {
        Mac m = Mac.getInstance("HmacSHA256");
        m.init(new SecretKeySpec(key.length == 0 ? new byte[32] : key, "HmacSHA256"));
        return m.doFinal(data);
    }

    private static byte[] concat(byte[]... parts) {
        ByteArrayOutputStream o = new ByteArrayOutputStream();
        for (byte[] p : parts) o.write(p, 0, p.length);
        return o.toByteArray();
    }
}
