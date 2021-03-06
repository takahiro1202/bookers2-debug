class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :follower, class_name:'Relationship', foreign_key:"follower_id", dependent: :destroy # フォローしている人取得(Userのfollowerから見た関係)
  has_many :followed, class_name:'Relationship', foreign_key:"followed_id", dependent: :destroy # フォローされている人取得(Userのfolowedから見た関係)
  has_many :following_user, through: :"follower", source: :followed # フォローする人(follower)は中間テーブル(Relationshipのfollower)を通じて(through)、フォローされる人(followed)と紐づく
  has_many :follower_user, through: :"followed", source: :follower #フォローされる人(followed) は中間テーブル(Relationshipのfollowed)を通じて(through)、 フォローする人(follower) と紐づく


  validates :name, length: {maximum: 20, minimum: 2}, uniqueness: true
  validates :introduction, length: { maximum: 50 }


  # 住所検索機能
  include JpPrefecture
  jp_prefecture :prefecture_code

  def perfect_name
    JpPrefecture::Prefecture.find(code: prefecture_code).try(:name)
  end

  def prefecture_name=(perfecture_name)
    self.prefecture_code = JpPrefecture::prefecture.find(name: prefecture_name).code
  end

  # ユーザーをフォローする
  def create(user_id)
    follower.create(followed_id: user_id)
  end
  # ユーザーのフォローを外す
  def destroy(user_id)
    follower.find_by(followed_id: user_id).destroy
  end
  # フォロー確認をおこなう
  def following?(user)
    following_user.include?(user)
  end
  attachment :profile_image, destroy: false

  def self.search(how,content)
    if how == "forward"
      @user = User.where("name LIKE?","#{content}%")
    elsif how == "backward"
      @user = User.where("name LIKE?","%#{content}")
    elsif how == "match"
      @user = User.where(name: content)
    elsif how == "partial"
      @user = User.where("name LIKE?","%#{content}%")
    else
      @user = User.all
    end
  end

end
