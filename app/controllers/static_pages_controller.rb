class StaticPagesController < ApplicationController
	DEFAULT_FORM_MESSAGE = "ここに変換したい文章を入力してくださいお願いしますどうかこの通りです"
  def home
		@version      = "v0.1.0"
  	@org_text     = (params[:org_text] != nil)? params[:org_text] : DEFAULT_FORM_MESSAGE
  	@short_text   = ""
  	@convert_text = ""
  	@org_text_length     = 0
  	@short_text_length   = 0
  	@convert_text_length = 0
  	@comp_rate           = 0

  	if params[:org_text] != nil
	  	result = TwLongText.new(params[:org_text].dup).to_short_text
	  	@short_text          = result[:short_text]
	  	@convert_text        = result[:convert_text]
	  	@org_text_length     = result[:org_text_length]
	  	@short_text_length   = result[:short_text_length]
	  	@convert_text_length = result[:convert_text_length]
	  	@comp_rate           = (1.0 - @short_text_length.to_f/@org_text_length.to_f) * 100
	  end
  end

  def help
  end
end
