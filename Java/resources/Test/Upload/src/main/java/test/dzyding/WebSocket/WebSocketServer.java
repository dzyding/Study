package test.dzyding.WebSocket;

import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.server.standard.SpringConfigurator;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import org.slf4j.Logger;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

@ServerEndpoint(value = "/ws/{userId}", configurator = SpringConfigurator.class)
@Component
public class WebSocketServer {

    private Logger logger = LoggerFactory.getLogger(WebSocketServer.class);

    // 静态变量，用来记录当前在线的链接数量，应设计成线程安全的
    private static int onlineCount = 0;

    // 记录每个用户下多个终端的连接
    private static Map<Long, Set<WebSocketServer>> userSocket = new HashMap<>();

    // 需要 session 来对用户发送数据，获取连接特征 userId
    private Session session;
    private Long userId;

    @OnOpen
    public void onOpen(@PathParam("userId") Long userId, Session session) throws IOException {
        this.session = session;
        this.userId = userId;
        onlineCount ++;

        if (userSocket.containsKey(this.userId)) {
            logger.debug("当前用户id:{}已有其他终端登陆", this.userId);
            userSocket.get(this.userId).add(this);
        }else {
            logger.debug("当前用户id:{}第一个终端登陆", this.userId);
            Set<WebSocketServer> addUserSet = new HashSet<>();
            addUserSet.add(this);
            userSocket.put(this.userId, addUserSet);
        }
        logger.debug("用户{}登陆的终端个数是{}", userId, userSocket.get(this.userId).size());
        logger.debug("当前在线用户数为:{}，所有终端个数为:{}", userSocket.size(), onlineCount);
    }

    @OnClose
    public void onClose() {
        if (userSocket.get(this.userId).size() == 0) {
            userSocket.remove(this.userId);
        }else {
            userSocket.get(this.userId).remove(this);
        }
        logger.debug("用户{}登陆的终端个数是{}", userId, userSocket.get(this.userId).size());
        logger.debug("当前在线用户数为:{}，所有终端个数为:{}", userSocket.size(), onlineCount);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        logger.debug("收到来自用户id为:{}的消息:{}", this.userId, message);
        if (session == null) logger.debug("session null");
    }

    @OnError
    public void onError(Session session, Throwable error) {
        logger.debug("用户id为:{}的连接发生错误", this.userId);
        error.printStackTrace();
    }

    public Boolean sendMessageToUser(Long userId, String message) {
        if (userSocket.containsKey(userId)) {
            logger.debug("给用户id为:{}的所有终端发送消息:{}", userId, message);
            for (WebSocketServer ws : userSocket.get(userId)) {
                logger.debug("sessionId为:{}", ws.session.getId());
                try {
                    ws.session.getBasicRemote().sendText(message);
                }catch (IOException e) {
                    e.printStackTrace();
                    logger.debug("给用户id为:{}发送消息失败", userId);
                    return false;
                }
            }
            return true;
        }
        logger.debug("发送错误：当前连接不包含id为:{}的用户", userId);
        return false;
    }
}
