import React from 'react'

import WaveVisCanvas from './WaveVisCanvas.jsx'

export default class EditorVisTable extends React.Component {
  render() {
    return (
      <div>
        <WaveVisCanvas songEngine={this.props.songEngine} />
      </div>
    );
  }
}
