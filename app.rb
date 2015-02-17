require "sinatra"
require "sinatra/reloader"
require "better_errors"
require "pry"
require "pg"
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

#ALL Sinatra based code!
# set is a method, think of it as a function in JS that takes in two parameters
set :conn, PG.connect(dbname: 'squad')


#settings.conn = PG.connect(dbname: 'sinatrasql')

before do
  @conn = settings.conn
end

#ROOT, take the user to a page that shows all the squads
get '/' do
  redirect '/squads'

  end

#INDEX
get '/squads' do
  squads = []
  @conn.exec("SELECT * FROM squads ORDER BY id ASC") do |result|
    result.each do |squad|
      squads << squad
      # the << is the same as : squads.push(author)
      # squads.append(author)
end
end
@squads = squads
  erb :index
  end


#NEW -this route should take the user to a page with a form that allows them to create a new squad
get '/squads/new' do
  erb :new
end

#SHOW
get '/squads/students' do
students_arr= []
@conn.exec("SELECT * FROM students") do |result_students|
    result_students.each do |student|
      students_arr << student
    end
  end
     @students = students_arr
erb :list_students
  end

#SHOW this route should take the user to a page that shows information about a single squad
get '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  students_arr= []
  squad= @conn.exec("SELECT * FROM squads WHERE id=($1)", [squad_id]) #You're only selecting from one squad
  @squad = squad[0]  # this is an array of ONE NAME
  @conn.exec("SELECT * FROM students WHERE squad_id =$1 ORDER BY id ASC",[squad_id]) do |result_students|
    result_students.each do |student|
      students_arr << student
    end
  end
  @students = students_arr
erb :show
end


##SHOW this route should take the user to a page with a form that allows them to edit an existing squad
get '/squads/:squad_id/edit' do
squad_id = params[:squad_id].to_i
squad= @conn.exec("SELECT * FROM squads WHERE id=($1)", [squad_id]) #You're only selecting from one squad
@squad = squad[0]
erb :edit
end


#SHOW
#this route should take the user to a page that shows them a form to create a new student
get '/squads/:squad_id/students/new' do
squad_id = params[:squad_id].to_i
squad= @conn.exec("SELECT * FROM squads WHERE id=($1)", [squad_id]) #You're only selecting from one squad
@squad = squad[0]
erb :new_student
end

#SHOW
#this route should take the user to a page that shows information about an individual student in a squad
get '/squads/:squad_id/students/:student_id' do
squad_id = params[:squad_id].to_i
student_id = params[:student_id].to_i
squad= @conn.exec("SELECT * FROM squads WHERE id=($1)", [squad_id]) #You're only selecting from one squad
@squad = squad[0]
student = @conn.exec("SELECT * FROM students WHERE id = ($1)", [student_id])
@student = student[0]
erb :show_student
  end






#SHOW
#this route should take the user to a page that shows them a form to edit a student's information
get '/squads/:squad_id/students/:student_id/edit' do
squad_id = params[:squad_id].to_i
student_id = params[:student_id].to_i
squad= @conn.exec("SELECT * FROM squads WHERE id=($1)", [squad_id]) #You're only selecting from one squad
@squad = squad[0]
student = @conn.exec("SELECT * FROM students WHERE id = ($1)", [student_id])
@student = student[0]
erb :edit_student
  end

#CREATE
#this route should be used for creating a new squad in an existing squad
post '/squads' do
  name = params[:sq_name]
  mascot = params[:mascot]
  @conn.exec("INSERT INTO squads (name, mascot) VALUES ($1, $2)", [name, mascot])
redirect '/squads'
end

#CREATE
post '/squads/:squad_id/students' do
  squad_id = params[:squad_id].to_i
  student_name = params[:student_name]
  age = params[:age].to_i
  spirit_animal = params[:spirit_animal]
  squadid = params[:squadid].to_i
  @conn.exec("INSERT INTO students (name, age, spirit_animal, squad_id) VALUES ($1, $2, $3, $4)", [student_name, age, spirit_animal, squadid])
redirect "/squads/#{params[:squadid].to_i}"
end



#UPDATE
#this route should be used for editing an existing squad
put '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  @conn.exec("UPDATE squads SET name = ($1), mascot = ($2) WHERE id=($3)", [params[:sq_name], params[:mascot], squad_id])
redirect '/squads'
end


#UPDATE
#this route should be used for editing an existing student in a squad
put '/squads/:squad_id/students/:student_id' do
  squad_id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  student_name = params[:student_name]
  age = params[:age].to_i
  spirit_animal = params[:spirit_animal]
  squadid = params[:squadid].to_i
  @conn.exec("UPDATE students SET name = ($1), age = ($2), spirit_animal = ($3), squad_id = ($4) WHERE id=($5)", [student_name, age, spirit_animal, squadid, student_id])
redirect "/squads/#{params[:squadid].to_i}"
end





#DELETE
#this route should be used for deleting an existing squad
delete '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  @conn.exec("DELETE FROM squads WHERE id= ($1)", [squad_id])
redirect '/squads'
end



#DELETE
#this route should be used for editing an existing student in a squad
delete '/squads/:squad_id/students/:student_id' do
  squad_id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  @conn.exec("DELETE FROM students WHERE id= ($1)", [student_id])
redirect "/squads"
end









