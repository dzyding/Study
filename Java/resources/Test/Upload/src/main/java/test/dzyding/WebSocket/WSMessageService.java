package test.dzyding.WebSocket;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service("webSocketMessageService")
public class WSMessageService {
    private Logger logger = LoggerFactory.getLogger(WSMessageService.class);
    // 声明 websocket 连接类
    private WebSocketServer webSocketServer = new WebSocketServer();

    public Boolean sendToAllTerminal(Long userId, String message) {
        logger.debug("向用户{}的消息{}", userId, message);
        if (webSocketServer.sendMessageToUser(userId, message)) {
            return true;
        }else {
            return false;
        }
    }
}
