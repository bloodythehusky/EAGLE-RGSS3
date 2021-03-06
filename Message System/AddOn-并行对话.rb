#==============================================================================
# ■ Add-On 并行对话 by 老鹰（http://oneeyedeagle.lofter.com/）
# ※ 本插件需要放置在【对话框扩展 by老鹰】之下
#==============================================================================
$imported ||= {}
$imported["EAGLE-MessagePara"] = true
#==============================================================================
# - 2019.4.10.17 新增指示
#==============================================================================
# - 本插件利用 对话框扩展 中的工具生成新的并行显示对话框
#--------------------------------------------------------------------------
# ○ 设置“并行对话序列”
#--------------------------------------------------------------------------
# - 利用下列格式进行编写，其中...替换成任意数目个“对话标签对”
#
#       <list[ {cond}][ ex]>...</list>
#
# -【可选】 [ {cond}] 替换成该并行对话序列产生所需要的条件脚本，
#                    被eval后返回不为false时，该并行对话序列才会激活
#      其中可用 s 代替 $game_switches， v 代替 $game_variables
#      p 代替 $game_player， e 代替 $game_map.events 或 $game_troop.members
#
# -【可选】 [ ex] 依据其它详细说明，替换成指定内容
#
# - 在任意场合生成“并行对话序列”：
#   利用脚本 MESSAGE_PARA.add(name, list_msg) 生成立即更新、只显示一次的序列
#     name 为任意的唯一标识符（若有重名，则先前存在的会被删除）
#     list_msg 为“对话标签对”的字符串（其中转义符需要用 \\ 代替 \）
#
#   示例：MESSAGE_PARA.add(:test, "<call test1><msg>...</msg>")
#      → 生成一个占位:test进行更新的并行对话序列，内容如字符串，并开始更新
#
#--------------------------------------------------------------------------
# ○ 设置“对话标签对”
#--------------------------------------------------------------------------
# - 利用下列格式进行编写，其中...替换成事件编辑器中显示文字时所写的文本内容即可
#
#       <msg[ {face_info}][ params]>...</msg>
#
# -【可选】 [ {face_info}] 替换成脸图的信息设置
#      face_info 为 face_name 与 face_index （用英语逗号或空格分隔开）
#      face_name - 替换成 Graphics/Faces 目录下的指定脸图名称（后缀名可以省略）
#      face_index - 替换成指定脸图的序号id（0-7）
#    示例： <msg {face_example, 5}>...</msg> - 对话显示face_example.png的5号脸图
#
# -【可选】 [ params] 替换成 变量名+参数值 的字符串
#      bg - 设置对话框的背景类型id（0普通，1暗色，2透明）（同VA默认）
#      pos - 设置对话框的显示位置类型id（0居上，1居中，2居下）（同VA默认）
#      w - 设置对话框绘制完成后、关闭前的等待帧数
#      t - 设置对话框关闭后、下一次对话开启前的等待帧数
#    示例： <msg w10>...</msg> - 设置该对话框绘制完成后，等待10帧后关闭
#
# - 注意：
#    ·在生成每一个对话框时，将会应用 Game_Message 的全部转义符参数作为初始值
#
#--------------------------------------------------------------------------
# ○ 在文本文件中预设
#--------------------------------------------------------------------------
# - 在指定的文本文件中，按下述格式填写，其中...替换成任意数目个“对话标签对”
#        <list[ {cond}][ name]>...</list>
#
# -【推荐】 name 替换成该并行对话序列的唯一名称，便于进行调用
#
# - 注意：
#    ·文本文件的编码必须为 UTF-8
#    ·文本文件不局限于.txt，只要其中只包含UTF-8编码的文本，可以为任意后缀名
#    ·由于技术受限，暂时无法读取VA加密档案中的文本文件，请不要放置于加密路径下
#      若已经有了能够读取加密档案路径下纯文本文件的方法，请替换全部EAGLE.load_text
#
# - 应用预设的“并行对话序列”：
#   在<list>...</list>标签对中，插入 <call name> ，其中 name 替换成对应的唯一名称
#   若name所对应的并行对话序列的cond判定成功，则会将它标签对中的全部内容复制放入
#
#    示例：<list><call test1><msg>...</msg></list>
#       → （若test1的cond不为false）使用test1名称的并行对话序列中的全部对话，
#          并在最后加上一个msg
#
# - 在任意场合呼叫预设的“并行对话序列”：
#   利用脚本 MESSAGE_PARA.call(name) 呼叫name名称的并行对话序列，只显示一次
#
#--------------------------------------------------------------------------
# ○ 对地图事件设置
#--------------------------------------------------------------------------
# - 事件页第一个指令为 注释 时，按下述格式填入该事件页的 “并行对话序列”：
#        <list[ {cond}][ params]>...</list>
#
#    ·其中...替换成任意数目个 “对话标签对”
#    ·若文本量超出单个注释窗口，可以拆分成多个连续的 注释 指令，脚本将一并读取
#    ·对于每个事件，同时只会执行一个并行对话序列
#
# - 示例（无参数）：
#      <list><msg>第一句台词</msg><msg>第二句台词</msg></list>
#      → 为该事件页添加 EVENT_MSG_TYPE_ID_DEFAULT 类型的对话组，
#         使用预设参数，依次显示这两句台词
#
# -【可选】<list> 中的 [ params] 替换成 参数名+参数值 的参数字符串
#      type - 设置该组并行对话的类型（0玩家接近事件时触发，1自动触发，2鼠标停留触发）
#     对于玩家接近时触发（每次玩家接近只会触发一次）：
#      d - 玩家与事件的距离（x差值的绝对值+y差值的绝对值）小于等于d时触发
#     对于自动触发：
#      t - 显示完成后的等待帧数
#      tc - 第一次触发前的等待帧数
#     对于鼠标停留触发【需 鼠标系统】：
#      d -与鼠标（所在格子）距离小于等于d时触发
#    示例： <list type0d3>...</list> - 设置玩家与事件间的距离不大于3时触发
#    示例： <list type1t60>...</list> - 设置为自动触发，两次触发间隔60帧
#
#--------------------------------------------------------------------------
# ○ 注意
#--------------------------------------------------------------------------
#  ·所有标签对均大小写敏感，在默认情况下，全部为小写字母
#  ·进行 场所移动 / Scene切换 时，会自动结束全部并行对话序列
#  ·打开S_ID_NO_MSG号开关时，会自动结束全部并行对话序列并禁止产生新的并行对话
#==============================================================================

#==============================================================================
# ○ 【设置部分】
#==============================================================================
module MESSAGE_PARA
  #--------------------------------------------------------------------------
  # ●【常量】当该ID号开关打开时，关闭全部并行对话，并且不再生成新对话
  # type_id => type_sym
  #--------------------------------------------------------------------------
  S_ID_NO_MSG = 0
  #--------------------------------------------------------------------------
  # ●【常量】对话框的参数预设
  #--------------------------------------------------------------------------
  PARA_MESSAGE_PARAMS = {
    :bg => 0, # 对话框背景类型id
    :pos => 2, # 对话框位置类型id
    :w => 40, # 对话完成后、关闭前的等待帧数
    :t => 1, # 当前对话框关闭后的等待帧数
  }
  #--------------------------------------------------------------------------
  # ●【常量】预设文本文件的路径（用 / 分隔）与文件名（含后缀名）的数组
  #--------------------------------------------------------------------------
  FILE_MSG_LIST_NAMES = ["Eagle/PARA.eagle"]
  #--------------------------------------------------------------------------
  # ●【常量】事件页注释里的并行对话类型
  # type_id => type_sym
  #--------------------------------------------------------------------------
  EVENT_MSG_ID_TO_TYPE = {
    0 => :near,
    1 => :auto,
    2 => :mouse,
  }
  #--------------------------------------------------------------------------
  # ●【常量】事件页默认并行对话类型id
  #--------------------------------------------------------------------------
  EVENT_MSG_TYPE_ID_DEFAULT = 0
  #--------------------------------------------------------------------------
  # ●【常量】事件页注释里的并行对话队列参数
  #--------------------------------------------------------------------------
  EVENT_PARAMS = {
    :near => { # id为0时“玩家接近触发”
      :d => 2, # 与玩家距离小于等于d时触发
    },
    :auto => { # id为1时“自动触发”
      :t => 180, # 循环触发后的等待帧数
      :tc => 0, # 第一次触发前的等待帧数
    },
    :mouse => { # id为2时“鼠标停留触发”
      :d => 0, # 与鼠标（所在格子）距离小于等于d时触发
    },
  }
end
#==============================================================================
# ○ 【读取部分】
#==============================================================================
module EAGLE
  #--------------------------------------------------------------------------
  # ● 读取事件页开头的注释组
  #--------------------------------------------------------------------------
  def self.event_comment_head(command_list)
    return "" if command_list.nil? || command_list.empty?
    t = ""; index = 0
    while command_list[index].code == 108 || command_list[index].code == 408
      t += command_list[index].parameters[0]
      index += 1
    end
    t
  end
  #--------------------------------------------------------------------------
  # ● 读取TXT文本
  #--------------------------------------------------------------------------
  def self.load_text(filename)
    text = ""
    File.open(filename, 'r') { |f| f.each_line { |l| text += l } }
    text.encode("UTF-8")
  end
end
#==============================================================================
# ○ 并行对话模块
#==============================================================================
module MESSAGE_PARA
  #--------------------------------------------------------------------------
  # ● 解析含并行对话序列的文本文件
  #--------------------------------------------------------------------------
  # hash - 存储解析出的全部 name => [cond_string, 并行对话文本list_msg]
  def self.parse_list_file(filename)
    hash = {}
    text = EAGLE.load_text(filename) rescue ""
    text.scan(/<list ?(\{.*?\})? ?(.*?)>(.*?)<\/list>/m).each do |params|
      hash[ params[1].to_sym ] = [ params[0], params[2] ]
    end
    hash
  end
  #--------------------------------------------------------------------------
  # ● 解析含并行对话序列的字符串
  #--------------------------------------------------------------------------
  # hash - 存储解析出的全部 name => 并行对话文本list_msg
  def self.parse_list_string(text)
    s = $game_switches; v = $game_variables; p = $game_player
    e = $game_map.events if SceneManager.scene_is?(Scene_Map)
    e = $game_troop.members if SceneManager.scene_is?(Scene_Battle)
    hash = {}
    text.scan(/<list ?(\{.*?\})? ?(.*?)>(.*?)<\/list>/m).each do |params|
      next if params[0] && eval(params[0]) == false
      hash[ params[1] ] = params[2]
    end
    hash
  end
  #--------------------------------------------------------------------------
  # ● 新增预设的并行对话序列
  #--------------------------------------------------------------------------
  def self.call(name_sym)
    name_sym = name_sym.to_sym if !name_sym.is_a?(Symbol)
    v = @lists_msgs[name_sym]
    return if v.nil?
    return if v[0] && eval(v[0]) != true
    add(name_sym, v[1])
  end
  #--------------------------------------------------------------------------
  # ● 新增一个并行对话序列
  #--------------------------------------------------------------------------
  # list_msg - "<msg params>foo</msg><msg params>foo</msg>"
  def self.add(id, list_msg)
    list = []
    # 执行快捷替换
    list_msg.gsub!(/<call (.*?)>/) {
      params = @list_msg[$1.to_sym]
      (params && eval(params[0]) == true) ? params[1] : ""
    }
    list_msg.scan(/<msg ?(\{.*?\})? ?(.*?)>(.*?)<\/msg>/m).each do |_params|
      # 解析脸图信息
      face_infos = parse_face_info(_params[0])
      # 解析对话框参数
      params = PARA_MESSAGE_PARAMS.dup # 初始化
      MESSAGE_EX.parse_param(params, _params[1])
      params[:id] = id # 记录执行事件的id号 / 特征id
      # [text, face_infos, message_params]
      list.push( [_params[2], face_infos, params] )
    end
    @lists[id].dispose if @lists[id]
    @lists[id] = MessagePara_List.new(list)
    return true
  end
  #--------------------------------------------------------------------------
  # ● 解析对话框脸图信息
  #--------------------------------------------------------------------------
  def self.parse_face_info(param_text)
    # param_text = "{face_name, face_index}"
    infos = []
    param_text =~ /\{(.*?)[, ]*(\d+)\}/i
    infos[0] = $1 || ""
    infos[1] = $2.to_i || 0
    infos
  end

  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------
  def self.init
    @lists = {} # 存储当前正在更新的并行对话列表
    @lock_count = [] # 当前锁定类型汇总
    @lists_msgs = {} # 存储预读取的全部并行对话序列 name_sym => [cond, list_msg]
    FILE_MSG_LIST_NAMES.each do |filename|
      @lists_msgs.merge!( parse_list_file(filename) )
    end
  end
  #--------------------------------------------------------------------------
  # ● 指定对话组存在？
  #--------------------------------------------------------------------------
  def self.list_exist?(id)
    @lists.has_key?(id)
  end
  #--------------------------------------------------------------------------
  # ● 直接结束
  #--------------------------------------------------------------------------
  def self.list_finish(id)
    return if !list_exist?(id)
    return if @lists[id].finish?
    @lists[id].finish
  end
  #--------------------------------------------------------------------------
  # ● 全部结束
  #--------------------------------------------------------------------------
  def self.all_finish(dispose = false)
    @lists.each { |id, l| l.finish; l.dispose if dispose }
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def self.update
    update_lock
    @lists.each { |id, l| l.update }
    @lists.delete_if { |id, l| l.finish? }
  end
  #--------------------------------------------------------------------------
  # ● 更新锁定
  #--------------------------------------------------------------------------
  def self.update_lock
    if $game_switches[S_ID_NO_MSG]
      return if lock?
      all_finish
      lock
    else
      return if !lock?
      unlock
    end
  end
  #--------------------------------------------------------------------------
  # ● 锁定
  #--------------------------------------------------------------------------
  def self.lock(type = :switch)
    @lock_count.push(type)
  end
  #--------------------------------------------------------------------------
  # ● 解锁
  #--------------------------------------------------------------------------
  def self.unlock(type = :switch)
    @lock_count.delete(type)
  end
  #--------------------------------------------------------------------------
  # ● 锁定？
  #--------------------------------------------------------------------------
  def self.lock?
    !@lock_count.empty?
  end
  #--------------------------------------------------------------------------
  # ● 生成对话框
  #--------------------------------------------------------------------------
  def self.get_new_window(info)
    # info[0]为待绘制文本 info[1]为脸图信息 info[2]为params的hash
    game_message = $game_message.clone
    game_message.add(info[0])
    game_message.face_name = info[1][0]
    game_message.face_index = info[1][1]
    game_message.background = info[2][:bg]
    game_message.position = info[2][:pos]
    game_message.visible = true
    game_message.win_params[:z] = 100
    game_message.pause_params[:v] = 0
    w = Window_Message_Para.new(game_message, info[2])
    return w
  end
  #--------------------------------------------------------------------------
  # ● 初始化参数组（地图事件页用）
  #--------------------------------------------------------------------------
  def self.event_init_params(hash)
    type = EVENT_MSG_ID_TO_TYPE[ (hash[:type] || EVENT_MSG_TYPE_ID_DEFAULT) ]
    hash = hash.merge(EVENT_PARAMS[type]) { |k, v1, v2| v1 }
    hash[:type] = type
    hash[:active] = false # 已经触发？
    hash
  end
end
#==============================================================================
# ○ 并行对话列表
#==============================================================================
class MessagePara_List # 该list中每一时刻只显示一个对话框
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(list)
    @list = list
    # 待处理的窗口信息队列 [[string, {infos}, {sym => value}]]
    @window = nil
    @wait = 0 # 在处理队列下一个需要显示的窗口前需要等待的时间
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    if @window
      @window.update
      if !@window.game_message.visible
        @window.dispose
        @window = nil
      end
    end
    if @window.nil? && !@list.empty?
      return if (@wait -= 1) > 0
      set_new_window
    end
  end
  #--------------------------------------------------------------------------
  # ● 设置新的对话框
  #--------------------------------------------------------------------------
  def set_new_window
    info = @list.shift # [string, params]
    @window = MESSAGE_PARA.get_new_window(info)
    @wait = info[-1][:t]
  end
  #--------------------------------------------------------------------------
  # ● 对话结束？
  #--------------------------------------------------------------------------
  def finish?
    @window.nil? && @list.empty?
  end
  #--------------------------------------------------------------------------
  # ● 直接结束
  #--------------------------------------------------------------------------
  def finish
    @list.clear
    @window.finish if @window
  end
  #--------------------------------------------------------------------------
  # ● 释放
  #--------------------------------------------------------------------------
  def dispose
    @window.dispose if @window
    @window = nil
  end
end
#==============================================================================
# ○ 并行对话框
#==============================================================================
class Window_Message_Para < Window_Message
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  def initialize(game_message, para_params)
    @game_message = game_message
    @para_params = para_params.dup
    super()
  end
  #--------------------------------------------------------------------------
  # ● 获取主参数
  #--------------------------------------------------------------------------
  def game_message
    @game_message
  end
  #--------------------------------------------------------------------------
  # ● 更新纤程
  #--------------------------------------------------------------------------
  def update_fiber
    if @fiber
      @fiber.resume
    elsif game_message.busy? && !game_message.scroll_mode
      @fiber = Fiber.new { fiber_main }
      @fiber.resume
    else
      game_message.visible = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 处理纤程的主逻辑
  #--------------------------------------------------------------------------
  def fiber_main
    game_message.visible = true
    update_background
    update_placement
    loop do
      process_all_text if game_message.has_text?
      process_input
      game_message.clear
      @gold_window.close
      Fiber.yield
      break
    end
    close_and_wait
    game_message.visible = false
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # ● 输入处理
  #--------------------------------------------------------------------------
  def process_input
    @para_params[:w].times { return if @para_params[:finish]; Fiber.yield }
  end
  #--------------------------------------------------------------------------
  # ● 处理输入等待
  #--------------------------------------------------------------------------
  def input_pause
  end
  #--------------------------------------------------------------------------
  # ● 监听“确定”键的按下，更新快进的标志
  #--------------------------------------------------------------------------
  def update_show_fast
  end
  #--------------------------------------------------------------------------
  # ● 强制结束当前对话框的更新
  #--------------------------------------------------------------------------
  def finish
    game_message.instant = true
    @para_params[:finish] = true
  end
  #--------------------------------------------------------------------------
  # ● 获取pop的弹出对象（需要有x、y方法）
  #--------------------------------------------------------------------------
  def eagle_pop_get_chara
    if SceneManager.scene_is?(Scene_Map) && game_message.pop_params[:id] == 0
      return $game_map.events[@para_params[:id]]
    end
    super
  end
end
#==============================================================================
# ○ 绑定
#==============================================================================
class << DataManager
  #--------------------------------------------------------------------------
  # ● 初始化模块
  #--------------------------------------------------------------------------
  alias eagle_message_para_init init
  def init
    MESSAGE_PARA.init
    eagle_message_para_init
  end
end
#==============================================================================
# ○ Game_Player
#==============================================================================
class Game_Player
  #--------------------------------------------------------------------------
  # ● 执行场所移动
  #--------------------------------------------------------------------------
  alias eagle_message_para_perform_transfer perform_transfer
  def perform_transfer
    if transfer?
      MESSAGE_PARA.all_finish(true)
      MESSAGE_PARA.lock(:player)
    end
    eagle_message_para_perform_transfer
    MESSAGE_PARA.unlock(:player)
  end
end
#==============================================================================
# ○ Scene_Base
#==============================================================================
class Scene_Base
  #--------------------------------------------------------------------------
  # ● 基础更新
  #--------------------------------------------------------------------------
  alias eagle_message_para_update_basic update_basic
  def update_basic
    eagle_message_para_update_basic
    MESSAGE_PARA.update
  end
  #--------------------------------------------------------------------------
  # ● 结束前处理
  #--------------------------------------------------------------------------
  alias eagle_message_para_pre_terminate pre_terminate
  def pre_terminate
    MESSAGE_PARA.all_finish(true)
    MESSAGE_PARA.lock(:scene_end)
    eagle_message_para_pre_terminate
    MESSAGE_PARA.unlock(:scene_end)
  end
end

#==============================================================================
# ○ 地图事件的并行对话
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 设置事件页
  #--------------------------------------------------------------------------
  alias eagle_message_para_setup_page setup_page
  def setup_page(new_page)
    eagle_message_para_setup_page(new_page)
    @eagle_message_para = {} # type => [list_msg, list_params] # 每种一个
    t = EAGLE.event_comment_head(@list)
    hash = MESSAGE_PARA.parse_list_string(t) # params => list_msg
    hash.each do |key, value|
      hash_ = {}; MESSAGE_EX.parse_param(hash_, key)
      hash_ = MESSAGE_PARA.event_init_params(hash_)
      @eagle_message_para[hash_[:type]] = [value, hash_]
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  alias eagle_message_para_update update
  def update
    eagle_message_para_update
    return if MESSAGE_PARA.lock?
    @eagle_message_para.each do |type, param|
      flag = method("check_message_para_#{type}").call(param[1])
      add_para_message(flag, param[0], param[1])
    end
  end
  #--------------------------------------------------------------------------
  # ● 新增一个并行对话序列（在一次激活后，只处理一次）
  #--------------------------------------------------------------------------
  def add_para_message(flag, list_msg, list_params)
    if flag # flag 为 true 代表满足对话生成条件
      if !list_params[:active]
        list_params[:active] = true
        MESSAGE_PARA.add(@id, list_msg)
      end
    else
      if list_params[:active]
        list_params[:active] = false
        MESSAGE_PARA.list_finish(@id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 检查“玩家邻近”的并行对话
  #--------------------------------------------------------------------------
  def check_message_para_near(list_params)
    d = distance_x_from($game_player.x).abs + distance_y_from($game_player.y).abs
    d <= list_params[:d]
  end
  #--------------------------------------------------------------------------
  # ● 检查“自动执行”的并行对话
  #--------------------------------------------------------------------------
  def check_message_para_auto(list_params)
    return true if MESSAGE_PARA.list_exist?(@id)
    list_params[:tc] -= 1
    if list_params[:tc] <= 0
      list_params[:tc] = list_params[:t]
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 检查“鼠标停留”的并行对话
  #--------------------------------------------------------------------------
  def check_message_para_mouse(list_params)
    x_ = Mouse.x / 32 + $game_map.display_x
    y_ = Mouse.y / 32 + $game_map.display_y
    d = distance_x_from(x_).abs + distance_y_from(y_).abs
    d <= list_params[:d]
  end
end
