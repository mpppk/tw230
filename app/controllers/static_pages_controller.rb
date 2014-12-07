class StaticPagesController < ApplicationController
	DEFAULT_FORM_MESSAGE = "ここに変換したい文章を入力してください."
  def home
		@version = "v0.1.0"
  	@org_text = (params[:org_text] != nil)? params[:org_text] : DEFAULT_FORM_MESSAGE
  	@short_text = ""
  	@convert_text = ""
  	if params[:org_text] != nil
	  	result = TwLongText.new(params[:org_text].dup).to_short_text
	  	@short_text = result[:short_text]
	  	@convert_text = result[:convert_text]
	  end
  end

  def help
  end
end
