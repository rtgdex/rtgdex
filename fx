# 分析备注名称
def analyze_remark_name():
    close_partner_dict = {'宝宝,猪,仙女,亲爱,老婆':0, '老公':0, '父亲,爸':0, '母亲,妈':0, '闺蜜,死党,基友':0}

    # 遍历好友数据
    for user in friends:
        for key in close_partner_dict.keys():
            # 判断该好友备注名是否包含close_partner_dict中的任意一个key
            name = key.split(',')
            for sub_name in name:
                if(sub_name in user.remark_name):
                    close_partner_dict[key] += 1
                    break


    name_list = ['最重要的她', '最重要的他', '爸爸', '妈妈', '死党']
    num_list = [x for x in close_partner_dict.values()]

    pie = Pie()
    pie.add("可能是你最亲密的人", [list(z) for z in zip(name_list, num_list)])
    pie.set_global_opts(title_opts=opts.TitleOpts(title="可能是你最亲密的人"))
    pie.set_series_opts(label_opts=opts.LabelOpts(formatter="{b}: {c}"))
    pie.render('data/你最亲密的人.html')



# 分析个性签名
def analyze_signature():

    # 个性签名列表
    data = []
    for user in friends:

        # 清除签名中的微信表情emoj，即<span class.*?</span>
        # 使用正则查找并替换方式，user.signature为源文本，将<span class.*?</span>替换成空
        new_signature = re.sub(re.compile(r"<span class.*?</span>", re.S), "", user.signature)

        # 只保留签名为1行的数据，过滤为多行的签名
        if(len(new_signature.split('\n')) == 1):
            data.append(new_signature)

    # 将个性签名列表转为string
    data = '\n'.join(data)

    # 进行分词处理，调用接口进行分词
    # 这里不使用jieba或snownlp的原因是无法打包成exe文件或者打包后文件非常大
    postData = {'data':data, 'type':'exportword', 'arg':'', 'beforeSend':'undefined'}
    response = post('http://life.chacuo.net/convertexportword',data=postData)
    data = response.text.replace('{"status":1,"info":"ok","data":["', '')
    # 解码
    data = data.encode('utf-8').decode('unicode_escape')

    # 将返回的分词结果json字符串转化为python对象，并做一些处理
    data = data.split("=====================================")[0]

    # 将分词结果转化为list，根据分词结果，可以知道以2个空格为分隔符
    data = data.split('  ')

    # 对分词结果数据进行去除一些无意义的词操作
    stop_words_list = [',', '，', '、', 'the', 'a', 'is', '…', '·', 'э', 'д', 'э', 'м', 'ж', 'и', 'л', 'т', 'ы', 'н', 'з', 'м', '…', '…', '…', '…', '…', '、', '.', '。', '!', '！', ':', '：', '~', '|', '▽', '`', 'ノ', '♪', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '\'', '‘', '’', '“', '”', '的', '了', '是', '你', '我', '他', '她','=', '\r', '\n', '\r\n', '\t', '以下关键词', '[', ']', '{', '}', '(', ')', '（', '）', 'span', '<', '>', 'class', 'html', '?', '就', '于', '下', '在', '吗', '嗯']
    tmp_data = []
    for word in data:
        if(word not in stop_words_list):
            tmp_data.append(word)
    data = tmp_data


    # 进行词频统计，结果存入字典signature_dict中
    signature_dict = {}
    for index, word in enumerate(data):

        print(u'正在统计好友签名数据，进度%d/%d，请耐心等待……' % (index + 1, len(data)))

        if(word in signature_dict.keys()):
            signature_dict[word] += 1
        else:
            signature_dict[word] = 1

    # 开始绘制词云
    name = [x for x in signature_dict.keys()]
    value = [x for x in signature_dict.values()]
    wordcloud = WordCloud()
    wordcloud.add('微信好友个性签名词云图', [list(z) for z in zip(name, value)], word_size_range=[1,100], shape='star')
    wordcloud.render('data/好友个性签名词云.html')


# 下载好友头像，此步骤消耗时间比较长
def download_head_image(thread_name):

    # 队列不为空的情况
    while(not queue_head_image.empty()):
        # 取出一个好友元素
        user = queue_head_image.get()

        # 下载该好友头像，并保存到指定位置，生成一个15位数的随机字符串
        random_file_name = ''.join([str(random.randint(0,9)) for x in range(15)])
        user.get_avatar(save_path='image/' + random_file_name + '.jpg')

        # 输出提示
        print(u'线程%d:正在下载微信好友头像数据，进度%d/%d，请耐心等待……' %(thread_name, len(friends)-queue_head_image.qsize(), len(friends)))

