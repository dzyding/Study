package test.dzyding.WebSocket;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/message")
public class MsgController {

    @Autowired
    private WSMessageService wsMessageService;

    @RequestMapping(value = "/send")
    @ResponseBody
    public String send(@RequestParam(value = "userId", required = true) Long userId,
                       @RequestParam(value = "message", required = true) String message)
    {
        if (wsMessageService.sendToAllTerminal(userId, message)) {
            return "发送成功";
        }else {
            return "发送失败";
        }
    }
}
