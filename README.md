随着新冠疫情的常态化，以上海为例，出示健康码、扫码场所码已经成了每天进出地铁、公司必备操作。对于上班工作，每天的场所码都是同一个地点，对应的场所码图片也不会发生变化，每次扫场所码的时候要不就是前面有很多人一起挤着，或者遇到下雨天不方便等情况。对于我自己而言，我会把场所码保存下来，方便下一次“扫场所码”，但由于存在图库，每次依然需要打开支付宝或者微信选择对应的图片进行扫描，所以就做了个工具，实现：一键打开健康码、自动保存场所码、一键打开存储的场所码。


## 小工具使用

 <img src="https://img-blog.csdnimg.cn/af7fdb3bd9884abf9e8bacfa04936511.png" width = 20% alt="图片名称" align=center />

如图所示提供两个按钮：

- 扫一扫 

扫一扫主要是为了扫场所码，它会扫码对应的二维码图片进行扫描（或者从相册进行读取），识别到对应的场所码信息会自动跳转到支付宝（当前只支持打开支付宝的场所码），并将这一次的结果保存到数据库中。如果下次需要同一个场所码，可以从列表中选择对应的场所码数据并点击直接跳转到场所码，不需要再进行手动扫描。


- 健康码

一键打开健康码


对于场所码的信息，在第一次添加的过程中会弹出提示框提示修改场所码的信息进行备注，当然也可以在对应的类目左滑进行编辑操作。

 <img src="https://img-blog.csdnimg.cn/94555e91ef1f4a51942f1a80c349e6d6.png" width = 20% alt="图片名称" align=center />
 
 <img src="https://img-blog.csdnimg.cn/0d09051321934a7e8936209a94b6d110.png" width = 20% alt="图片名称" align=center />
