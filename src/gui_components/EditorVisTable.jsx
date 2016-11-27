import React from 'react'

import LiveFreqVisCanvas from './LiveFreqVisCanvas.jsx'
import WaveVisCanvas from './WaveVisCanvas.jsx'

export default class EditorVisTable extends React.Component {
  render() {
    return (
      <div>
        <WaveVisCanvas songEngine={this.props.songEngine} />
        <LiveFreqVisCanvas songEngine={this.props.songEngine} />
      </div>
    );
  }
}
