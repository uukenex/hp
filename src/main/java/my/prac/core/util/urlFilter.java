package my.prac.core.util;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * sub.dev-apc.com 도메인에서는 /bom, /car, /kakao 경로만 허용.
 * 그 외 도메인(로컬 등)은 모두 통과.
 */
public class urlFilter implements Filter {

    private static final String TARGET_DOMAIN   = "sub.dev-apc.com";
    private static final String[] ALLOWED_PATHS = { "/bom", "/car", "/kakao" };

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String serverName = request.getServerName();

        if (TARGET_DOMAIN.equals(serverName)) {
            String uri = request.getRequestURI();
            String contextPath = request.getContextPath();
            // contextPath 제거 후 실제 경로만 비교
            String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

            if (!isAllowed(path)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }

        chain.doFilter(req, res);
    }

    private boolean isAllowed(String path) {
        for (String allowed : ALLOWED_PATHS) {
            if (path.startsWith(allowed)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void destroy() {}
}
