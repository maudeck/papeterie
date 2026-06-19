<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Test Front Controller</title>
</head>

<body>

<h1>Projet Test Framework</h1>



<a href="test">Tester FrontControllerServlet (GET)</a>

<!-- Formulaire pour tester POST -->
<form method="post" action="test">
    <input type="text" name="message" placeholder="Tape un message">
    <button type="submit">Envoyer POST</button>
</form>

</body>
</html>