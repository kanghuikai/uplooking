<%@ page contentType="text/html; charset=GBK"%> 
<%@ page import="java.sql.*,javax.sql.DataSource,javax.naming.*"%> 
<html> 
<head><title>test.jsp</title></head> 
<body bgcolor="#ffffff"> 
<h1>test Tomcat</h1> 
<% 
try 
{ 
Context initCtx=new InitialContext(); 
DataSource ds = (DataSource)initCtx.lookup("java:comp/env/jdbc/TestDB"); 
Connection conn=ds.getConnection(); 
out.println("data from database:<br>"); 
Statement stmt=conn.createStatement(); 
ResultSet rs =stmt.executeQuery("select id, foo, bar from testdata"); 
while(rs.next()) 
{ 
out.println(rs.getInt("id")); 
out.println(rs.getString("foo")); 
out.println(rs.getString("bar")); 
} 
rs.close(); 
stmt.close(); 
} 
catch(Exception e) 
{ 
e.printStackTrace(); 
} 
%> 
</body> 
</html> 
