type WifiState = {
  ACTIVE: WifiStateConfig,
  INACTIVE: WifiStateConfig,
}
type WifiStateConfig = {
  symbol: string;
  className: string;
}

const WIFI_STATE: WifiState = {
  ACTIVE: {
    symbol: '',
    className: 'wifi-active',
  },
  INACTIVE: {
    symbol: '󰖪',
    className: 'wifi-inactive',
  },
}

export default function Network() {
  const currentState = 'ACTIVE';
  return (
    <box class="button-panel">
      <box class={`wifi ${WIFI_STATE[currentState].className}`}>
        {WIFI_STATE[currentState].symbol}
      </box>
    </box>
  )
}
