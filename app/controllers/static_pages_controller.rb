class StaticPagesController < ApplicationController
	DEFAULT_FORM_MESSAGE = "ここに変換したい文章を入力してください."
  def home
  	@initial_contents = (params[:org_text] != nil)? params[:org_text] : DEFAULT_FORM_MESSAGE
  	@short_text = ""
  	if params[:org_text] != nil
	  	tw = TwLongText.new(params[:org_text])
	  	@short_text = tw.to_short_text
	  end
  end

  def help
  end
end
