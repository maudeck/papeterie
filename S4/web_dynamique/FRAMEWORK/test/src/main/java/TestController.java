package mg.itu;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import mg.itu.annotation.Controller;

@Controller
public class TestController extends BaseController {
    public void execute(String methodName, HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        out.println("<h1>TestController</h1>");
        out.println("<p>Méthode appelée : " + methodName + "</p>");
    }
}