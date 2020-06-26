<%--
  Created by IntelliJ IDEA.
  User: Сергей
  Date: 02.06.2020
  Time: 4:33
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import = "java.io.*,java.util.*" %>
<%@ page import="java.sql.*"%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html>
  <head>
      <meta charset="utf-8">
    <title>MyProject</title>
    <%!
        HttpServletRequest rq;
        HttpServletResponse rs;
        boolean isOwner=false;
        String currentTable;
        boolean isComment=false;
        boolean isUpdating=false;
        String updText;
        boolean isSearching=false;
    %>
    <%
        rq =request;
        rs =response;
        PrintWriter write = response.getWriter();
        rq.setCharacterEncoding("UTF-8");
    %>

  </head>
  <body style="padding-left: 20px">
  <%if(rq.getParameter("deleteComment")!=null){
      try{
          Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
          String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
          Connection connection = java.sql.DriverManager.getConnection(url);
          String sql="delete from "+currentTable+" where Id="+rq.getParameter("deleteComment");
          Statement statement=connection.createStatement();
          int rows = statement.executeUpdate(sql);
          connection.close();
      }
      catch (Exception e){
          write.println(e.getMessage());
      }
  }%>
  <%
      if(rq.getParameter("confirmOwner")!=null)
      try {
          Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
          String url = "jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
          Connection connection = java.sql.DriverManager.getConnection(url);
          String query = "SELECT * FROM links";
          Statement statement = connection.createStatement();
          ResultSet resultSet = statement.executeQuery(query);
          int secretPassword=0;

          while (resultSet.next())
          {
              secretPassword = resultSet.getInt(4)+resultSet.getInt(5);
              break;
          }
          String scPassword = Integer.toString(secretPassword);
          if(rq.getParameter("ownerPassword").equals(scPassword))
          {
             isOwner=true;
          }
          else {
              write.println("блин");
          }
          connection.close();
      }
      catch(SQLException e){
write.println(e.getMessage());
      }
  %>
  <form method="post" >
      <button name="owner" style="border:none; padding:0px; margin: 0px; background-color: #ffffff;"><h2>Перечень ссылок</h2></button>
      <button name="searchLink" type="submit">Поиск</button>
  </form>
  <%if(rq.getParameter("searchLink")!=null){
      isSearching=true;
  }
  if(rq.getParameter("closeSearching")!=null){
      isSearching=false;
  }
  if(isSearching)
  {%>
    <form method="post">
        <input name="searchText"/>
        <button name="searchButton" type="submit">Найти</button>
        <button name="closeSearching">Закрыть</button>
    </form>
  <%}%>
  <%
  if(rq.getParameter("searchButton")!=null){
  try {
      Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
      String url = "jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
      Connection connection = java.sql.DriverManager.getConnection(url);
      String query = "SELECT * FROM links where description like '%"+rq.getParameter("searchText")+"%'";
      Statement statement = connection.createStatement();
      ResultSet resultSet = statement.executeQuery(query);
      while (resultSet.next())
      {%>
  <form method="post" style="background-color: #ffaaff; border-radius: 20px; padding:10px 20px; width: 140px">
      <a name = "linkParam" href="<%=resultSet.getString("link")%>"><%=resultSet.getString("description")%></a>
      <div>Полезно: <%=resultSet.getInt(4)%></div>
      <div>Бесполезно: <%=resultSet.getInt(5)%></div>
  </form>

  <%}
      connection.close();
  }
  catch (SQLException e){
      write.println(e.getMessage());
  }

  }
  %>

  <%
      if(rq.getParameter("owner")!=null)
      {
  %>
  <form method="post" >
  <input name="ownerPassword"/>
  <button name="confirmOwner">Подтвердить</button>
  </form>
  <%
      }
  %>
  <%
      if(isOwner==true)
      {%>
  <form method="post" >
      <button name="createBt" type="submit">Добавить ссылку</button>
  </form>
  <%
      }
  %>
  <%
      if(rq.getParameter("createBt")!=null)
      {
  %>
  <form method="post">
      <input name="linkPut"/>
      <input name="linkDescription"/>
      <button name="submitLink" type="submit">Добавить</button>
  </form>
  <%}%>
<% try {
    Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
    String url = "jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
    Connection connection = java.sql.DriverManager.getConnection(url);
    String query = "SELECT * FROM links";
    Statement statement = connection.createStatement();
    ResultSet resultSet = statement.executeQuery(query);
    while (resultSet.next())
    {%>
<form method="post" style="background-color: #cccccc; border-radius: 20px; padding:10px 20px; width: 540px">
    <a name = "linkParam" href="<%=resultSet.getString("link")%>"><%=resultSet.getString("description")%></a>
    <div>Полезно: <%=resultSet.getInt(4)%></div>
    <div>Бесполезно: <%=resultSet.getInt(5)%></div>
    <button type="submit" value="<%=resultSet.getInt("Id")%>" name="good">Полезно</button>
    <button type="submit" value = "<%=resultSet.getInt("Id")%>" name="bad">Бесполезно</button>
    <button type="submit" name="comments" value="<%=resultSet.getInt("Id")%>">Комментарии</button>
    <button type="submit" name="comment" value="<%=resultSet.getInt("Id")%>">Оставить комментарий</button>
    <%if(isOwner){%>
    <button style="background-color: #55ccff" type="submit" name="deleteLink" value="<%=resultSet.getInt("Id")%>">Удалить</button>
    <%}%>
</form>

    <%}
connection.close();
}
catch (SQLException e){
    write.println(e.getMessage());
}
%>

  <% if(rq.getParameter("submitLink")!=null && rq.getParameter("linkPut")!="" && rq.getParameter("linkDescription")!=""){
      try{
          Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
          String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
          Connection connection = java.sql.DriverManager.getConnection(url);
          String sql="INSERT INTO links(link,description, plus, minus) VALUES ('" + rq.getParameter("linkPut") + "','" + rq.getParameter("linkDescription") +"',0, 0)";
          Statement statement=connection.createStatement();
          int rows = statement.executeUpdate(sql);
          if (rows>0){
              write.println("<h2>great</h2>");
          }
          else{
              write.println("<h2>bad</h2>");
          }

rs.sendRedirect("");
          connection.close();
      }
      catch (SQLException e){
          write.println(e.getMessage());
      }
  }
      if(rq.getParameter("linkPut")=="" || rq.getParameter("linkDescription")=="")
      {write.println("Заполните поля");}

  %>
  <%
      if(rq.getParameter("updComment")!=null)
      {
          try{
          isUpdating=true;
          updText=rq.getParameter("updComment");
          }
          catch (Exception e){
              write.println(e.getMessage());
          }
      }
  %>
  <%
      if(isUpdating)
  {%>
  <form method="post">
      <input name="updatingText"/>
      <button name="confirmUpd" type="submit">Изменить</button>
  </form>
  <%}
      if(rq.getParameter("confirmUpd")!=null){
         try{
              Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
              String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
              Connection connection = java.sql.DriverManager.getConnection(url);
              String sql="update "+currentTable+" set Description='"+rq.getParameter("updatingText")+"' where Id="+updText;
              Statement statement=connection.createStatement();
              int rows = statement.executeUpdate(sql);
              if (rows>0){
                  write.println("<h2>great</h2>");
              }
              else{
                  write.println("<h2>bad</h2>");
              }
              connection.close();
          }
          catch (SQLException e){
              write.println(e.getMessage());
          }
          rs.sendRedirect("");
      isUpdating=false;
      }



  %>
<%
    if(rq.getParameter("good")!=null){
        try{
            Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
            String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
            Connection connection = java.sql.DriverManager.getConnection(url);
            String sql="update links set plus=plus+1 where Id="+rq.getParameter("good");
            Statement statement=connection.createStatement();
            int rows = statement.executeUpdate(sql);
            if (rows>0){
                write.println("<h2>great</h2>");
            }
            else{
                write.println("<h2>bad</h2>");
            }
            connection.close();
        }
        catch (SQLException e){
            write.println(e.getMessage());
        }
        rs.sendRedirect("");
    }

    if(rq.getParameter("bad")!=null){
        try{
            Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
            String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
            Connection connection = java.sql.DriverManager.getConnection(url);
            String sql="update links set minus=minus+1 where Id="+rq.getParameter("bad");
            Statement statement=connection.createStatement();
            int rows = statement.executeUpdate(sql);
            if (rows>0){
                write.println("<h2>great</h2>");
            }
            else{
                write.println("<h2>bad</h2>");
            }
            connection.close();
        }
        catch (SQLException e){
            write.println(e.getMessage());
        }
        rs.sendRedirect("");
    }
    if(rq.getParameter("deleteLink")!=null){
        try{
            Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
            String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
            Connection connection = java.sql.DriverManager.getConnection(url);
            String sql="delete from links where Id="+rq.getParameter("deleteLink");
            Statement statement=connection.createStatement();
            int rows = statement.executeUpdate(sql);
            if (rows>0){
                write.println("<h2>great</h2>");
            }
            else{
                write.println("<h2>bad</h2>");
            }
            connection.close();
        }
        catch (SQLException e){
            write.println(e.getMessage());
        }
        rs.sendRedirect("");
    }
%>
  <%
  if(rq.getParameter("comment")!=null)
  {
      %>
<form method="post">
    <input name="textComment"/>
    <button name="addComment" type="submit" value="<%=rq.getParameter("comment")%>">Добавить комментарий</button>
</form>
<%
  }
  %>

  <%if(rq.getParameter("addComment")!=null && rq.getParameter("textComment")!=""){
      try{
          Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
          String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
          Connection connection = java.sql.DriverManager.getConnection(url);
          String sql="create table tb"+rq.getParameter("addComment")+"(Id int identity(1,1), Description nvarchar(200));";
          Statement statement=connection.createStatement();
          int rows = statement.executeUpdate(sql);
          connection.close();
      }
      catch (SQLException e){
      }
      try{
          Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
          String url ="jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
          Connection connection = java.sql.DriverManager.getConnection(url);
          String sql="create table tb"+rq.getParameter("addComment")+"(Description nvarchar(200));";
          Statement statement=connection.createStatement();
          int rows2 = statement.executeUpdate("insert into tb"+rq.getParameter("addComment")+"(Description) values ('"+rq.getParameter("textComment")+"')");
          connection.close();
      }
      catch (SQLException e){
          write.println(e.getMessage());
      }
  }%>
  <%
  if(rq.getParameter("comments")!=null){
      isComment=true;
      currentTable="tb"+rq.getParameter("comments");
  }
  if(isComment){
      try {
          Driver driver = new com.microsoft.sqlserver.jdbc.SQLServerDriver();
          String url = "jdbc:sqlserver://localhost:49670;databaseName=CurrentBase;integratedSecurity=true";
          Connection connection = java.sql.DriverManager.getConnection(url);
          String query = "SELECT * FROM "+currentTable;
          Statement statement = connection.createStatement();
          ResultSet resultSet = statement.executeQuery(query);
          %>
  <form method="post">
      <button name="closeComment" type="submit">Закрыть комментарии</button>
  </form>
  <%
          while (resultSet.next())
          {%>
  <form method="post" style="background-color: #eeeeee; border-radius: 20px; padding:10px 20px; width: 540px ">
      <div><%=resultSet.getString(2)%></div>
      <%if(isOwner){%>
      <button style="background-color: #55ccff" name="updComment" value="<%=resultSet.getInt(1)%>" type="submit">Редактировать</button>
      <button style="background-color: #55ccff" name="deleteComment" value="<%=resultSet.getInt(1)%>"  type="submit">Удалить</button>
  </form>
  <%}%>
          <%}
          connection.close();
      }
      catch (Exception e){

      }
  }
  %>
  <%
  if(rq.getParameter("closeComment")!=null)
  {
      isComment=false;
      rs.sendRedirect("");
  }
  %>

  </body>
</html>
