<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html xmlns:th="http://www.thymeleaf.org"
      xmlns:sec="http://www.thymeleaf.org/thymeleaf-extras-springsecurity3"
      xmlns:layout="http://www.ultraq.net.nz/thymeleaf/layout">
<head>
    <title>WebScoket广播式</title>
    <script src="/sockjs.js"></script>
    <script src="/stomp.js"></script>
    <script src="/jquery.js"></script>
</head>
<body onload="disconnect()">
<button id="connect" onclick="connect()">连接</button>
<button id="disconnect" onclick="disconnect()" disabled="disabled">断开连接</button><br/>
<div id="inputDiv">
    输入名称：<input type="text" id="name"/><br/>
    <button id="sendName" onclick="sendName()">发送</button><br/>
    <p id="response"></p>
</div>
<script>
    var stompClient = null;
    //设置连接状态控制显示隐藏
    function setConnected(connected)
    {
        $("#connect").attr("disabled",connected);
        $("#disconnect").attr("disabled",!connected);
        if(!connected) {
            $("#inputDiv").hide();
        }else{
            $("#inputDiv").show();
        }
        $("#reponse").html("");
    }
    //连接
    function connect()
    {
        var socket = new SockJS("/websocket");
        stompClient = Stomp.over(socket);
        stompClient.connect({},function (frame) {
            setConnected(true);
            console.log("connected : "+frame);
            stompClient.subscribe('/user/' + 1234 + '/message2',function (response) {
                showResponse("我说：" + response.body);
            })
            stompClient.subscribe('/user/' + 123 + '/message',function (response) {
                showResponse("他说：" + response.body);
            })
            stompClient.subscribe('/topic/getResponse',function (response) {
                showResponse("群发说：" + response.body);
            })
        })
    }
    //断开连接
    function disconnect(){
        if(stompClient!=null)
        {
            stompClient.disconnect();
        }
        setConnected(false);
        console.log("disconnected!");
    }
    //发送名称到后台
    function sendName(){
        var name = $("#name").val();
        stompClient.send("/app/message2",{},JSON.stringify({'message':name}));
    }
    //显示socket返回消息内容
    function showResponse(message)
    {
        $("#response").html($("#response").html() + message + "<br>");
    }
</script>
</body>
</html>
