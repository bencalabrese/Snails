class CatsController < ControllerBase
  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def create
    # byebug
    @cat = Cat.new(params['cat'])
    @cat.save
    flash['success'] = 'GREAT SUCCESS'
    redirect_to '/cats'
  end

end
