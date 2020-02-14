require "../spec_helper"

module ViewSpec
  describe "Clear::View" do
    it "recreate the views on migration" do
      temporary do
        Clear::View.register do |view|
          view.name "year_days"
          view.query <<-SQL
            SELECT date.day::date as day
            FROM   generate_series(
              date_trunc('day', NOW()),
              date_trunc('day', NOW() + INTERVAL '365 days'),
              INTERVAL '1 day'
            ) AS date(day);
          SQL
        end

        Clear::Migration::Manager.instance.reinit!
        # Create the view
        Clear::Migration::Manager.instance.apply_all

        Clear::SQL.select.from("year_days").agg("count(day)", Int64).should eq(366)
      end
    end



  end

end