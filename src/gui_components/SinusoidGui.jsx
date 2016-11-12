import React from 'react'

import SideBar from './SideBar.jsx'
import ContentTable from './ContentTable.jsx'

export default class SinusoidGui extends React.Component {
  render() {
    return (
      <div className="wrapper">
        <SideBar />
        <ContentTable />
      </div>
    );
  }
}
