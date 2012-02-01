class VotesController < ApplicationController
  def authentication_options
    @island_is_url = DB_CONFIG[RAILS_ENV]['island_is_url']
  end

  def authenticate_from_island_is
    if Vote.authenticate_from_island_is(params[:token],request)
      redirect_to :action=>:authentication_error
    else
      redirect_to :action=>:get_ballot
    end
  end

  def authentication_error
  end

  def get_ballot
    #Rails.cache.write(request.session_options[:id],"19654654434343"+rand(54545454).to_s)
    @neighborhood_id = params[:neighborhood_id] ? params[:neighborhood_id] : 99
    Rails.logger.info(request.session_options[:id])
    Rails.cache.write(request.session_options[:id],"gggffiud12345")
    unless voter_national_identity_hash = Rails.cache.read(request.session_options[:id])
      redirect_to :action=>:authentication_error
      return false
    end
    @reykjavik_budget_ballot = ReykjavikBudgetBallot.new
    @vote_count = Vote.where(:user_id_hash=>voter_national_identity_hash).count
  end

  def post_vote
    Rails.logger.info(request.session_options[:id])
    unless voter_national_identity_hash = Rails.cache.read(request.session_options[:id])
      response = [:error=>true, :message=>"Not logged in", :vote_ok=>false]
    else
      if Vote.create(:user_id_hash=>voter_national_identity_hash, :payload_data => params[:vote],
                     :localtime=>Time.now, :client_ip_address=>request.remote_ip, :neighborhood_id =>params[:neighborhood_id])
        response = [:error=>false, :message=>"Vote created", :vote_ok=>true]
      else
        response = [:error=>true, :message=>"Could not create vote", :vote_ok=>false]
      end
    end
    respond_to do |format|
      format.json { render :json => response }
    end
  end
end