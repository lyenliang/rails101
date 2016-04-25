class GroupsController < ApplicationController

  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

  # 列出所有的討論版，可以選擇各個單版
  def index
    @groups = Group.all
  end

  # 裡面會有表單，填完以後可以送出
  def new
    @group = Group.new
  end

  # new 送出來的表單到 create 這個 action，新增一筆資料
  def create
    @group = current_user.groups.new(group_params)
    
    if @group.save
      current_user.join!(@group)
      redirect_to groups_path
    else
      render :new
    end
  end

  # edit 送出來的表單可以到 update 這個 action，更新該筆資料
  def update
    @group = current_user.groups.find(params[:id])

    if @group.update(group_params)
      redirect_to groups_path, notice: "修改討論版成功"
    else
      render :edit
    end
  end

  # 顯示討論版版名跟簡介
  def show
    @group = Group.find(params[:id])
    @posts = @group.posts
  end

  # 裡面會有表單呈現現有資料來，填完資料後可以送出
  def edit
    @group = Group.find(params[:id])
  end

  # 送出刪除請求，刪除該筆資料
  def destroy
    @group = current_user.groups.find(params[:id])
    @group.destroy
    redirect_to groups_path, alert: "討論版已刪除"
  end

  def join
    @group = Group.find(params[:id])

    if !current_user.is_member_of?(@group)
      current_user.join!(@group)
      flash[:notice] = "加入本討論版成功！"
    else
      flash[:warning] = "你已經是本討論版成員了！"
    end

    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])

    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "已退出本討論版！"
    else
      flash[:warning] = "你不是本討論版成員，怎麼退出 XD"
    end

    redirect_to group_path(@group)
  end

  private
  def group_params
    params.require(:group).permit(:title, :description)
  end
end
