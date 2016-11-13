import React from 'react'

export default class EditorSettings extends React.Component {
  constructor(props) {
    super(props);
    this.state = {renderingStatus: ''};
  }

  render() {
    return (
      <div>
        <select>
          <option>LiveScript</option>
        </select>
        <button id="play_button">Ctrl+Enter to play</button>
        <span id="renderingStatus" ref="renderingStatus">
          {this.state.renderingStatus}
        </span>
      </div>
    );
  }
  componentDidMount() {
    this.props.songEngine.addListener('rendering_status', (msg) => {
      this.setState({renderingStatus: msg});
    });
    this.props.songEngine.addListener('error', (msg) => {
      this.setState({renderingStatus: msg});
    });
  }
}
