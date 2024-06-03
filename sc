<script src="js/jquery-3.6.1.min.js"></script>
	<script type="text/javascript">
	function uploadimg(file) {console.log(file.files);
		//选择图片上传
		if (file.files && file.files[0]) {
			//创建文件读取对象
            var reader = new FileReader();
			//读取图片
			reader.readAsDataURL(file.files[0]);
			//onload该事件在读取操作完成时触发
            reader.onload = function (evt) {
                $.post(
					//上传的路径
					"imgLoad.php",
					{imgbase64: evt.target.result},
					function(rs){
						//将图片显示再界面上
						$('#uploaderFiles').html(
						'<li class="weui-uploader__file"' + 
						'style="background-image:url(' + evt.target.result + ')"></li>'
						);
               //
			   var obj=$.parseJSON(rs);
			   alert(obj.msg);
					}
				);
			};
             
		}
	}
	</script>
