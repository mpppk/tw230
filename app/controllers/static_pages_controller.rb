class StaticPagesController < ApplicationController
	DEFAULT_FORM_MESSAGE = "ここに変換したい文章を入力してください."
  def home
		@version = "v0.1.0"
  	@org_text = (params[:org_text] != nil)? params[:org_text] : DEFAULT_FORM_MESSAGE
  	@short_text = ""
  	@convert_text = ""
  	if params[:org_text] != nil
	  	tw = TwLongText.new(params[:org_text].dup)
	  	@short_text = tw.to_short_text
	  end
  end

  def help
  end
end
