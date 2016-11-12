import React from 'react'

export default class EditorSettings extends React.Component {
  render() {
    return (
      <div>
        <select>
          <option>LiveScript</option>
        </select>
        <button id="play_button">Ctrl+Enter to play</button>
        <span id="rendering_status"></span>
      </div>
    );
  }
}
