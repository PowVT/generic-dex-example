import React from 'react'
import { PageHeader } from 'antd';

export default function Header(props) {
  return (
    <div onClick={()=>{
      window.open("https://github.com/austintgriffith/scaffold-eth");
    }}>
      <PageHeader
        title="⚖️ DEX test"
        subTitle=""
        style={{cursor:'pointer'}}
      />
    </div>
  );
}
