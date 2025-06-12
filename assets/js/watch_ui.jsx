import React, { useState } from "react";
import channel from "./ui_socket.js"

export default App = () => {
  const [time, setTime] = useState("12:00:00");
  const [date, setDate] = useState("--/---/--");
  const [indiglo, setIndiglo] = useState("white");
  const handleEvent = event => channel.push(event, {});
  channel.on("setIndiglo", _payload => setIndiglo("cyan"));
  channel.on("unsetIndiglo", _payload => setIndiglo("white"));
  channel.on("setTimeDisplay", payload => setTime(payload.time));
  channel.on("setDateDisplay", payload => setDate(payload.date));
  return (
    <svg width="250" height="250">
      <image href="/images/watch.gif"></image>
      <rect onMouseDown={e => handleEvent("top-left-pressed")}
            onMouseUp={e => handleEvent("top-left-released")}
            x="2" y="60" width="12" height="12"
            stroke="white" strokeWidth="1" fill="transparent" />
      <rect onMouseDown={e => handleEvent("bottom-left-pressed")}
            onMouseUp={e => handleEvent("bottom-left-released")}
            x="2" y="160" width="12" height="12"
            stroke="white" strokeWidth="1" fill="transparent" />
      <rect onMouseDown={e => handleEvent("top-right-pressed")}
            onMouseUp={e => handleEvent("top-right-released")}
            x="207" y="58" width="12" height="12"
            stroke="white" strokeWidth="1" fill="transparent" />
      <rect onMouseDown={e => handleEvent("bottom-right-pressed")}
            onMouseUp={e => handleEvent("bottom-right-released")}
            x="209" y="160" width="12" height="12"
            stroke="white" strokeWidth="1" fill="transparent" />
      <rect x="52" y="100" width="120" height="50" fill={indiglo} />
      <text x="95" y="114" fontFamily="monospace" fontSize="10px" fill="black" fontWeight="bold" xmlSpace="preserve">{date}</text>
      <text x="73" y="137" fontFamily="monospace" fontSize="18px" fill="black" fontWeight="bold" xmlSpace="preserve">{time}</text>
    </svg>
  );
}