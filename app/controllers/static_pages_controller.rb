class StaticPagesController < ApplicationController
  def home
  	@short_text = ""
  	if params[:org_text] != nil
	  	tw = TwLongText.new(params[:org_text])
	  	@short_text = tw.to_short_text
	  end
  end

  def help
  end
end
