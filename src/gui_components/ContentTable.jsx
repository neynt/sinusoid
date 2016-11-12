import React from 'react'
import SongEditor from './SongEditor.jsx'

export default class ContentTable extends React.Component {
  render() {
    return (
      <div className="content">
        <SongEditor />
      </div>
    );
  }
}

