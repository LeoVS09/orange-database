------------------------------------------------------------------------------------------------------------------------

insert into app_public.languages(name, code) values
('russian', 'ru'),
('english', 'en');

------------------------------------------------------------------------------------------------------------------------

insert into app_public.countries(name) values
	('Russia'),
	('Canada'),
	('Belarus');

do $$
    declare
        russia_id uuid;
    begin
        select app_public.countries.id
            into russia_id
            from app_public.countries
            where name = 'Russia'
            limit 1;

        insert into app_public.cities(name, country_id) values
            ('Moscow', russia_id),
            ('Saint-Petersburg', russia_id),
            ('Volgograd', russia_id),
            ('Novosibirsk', russia_id);
    end
$$;

------------------------------------------------------------------------------------------------------------------------

do $$
   declare
       peter_id uuid;
   begin
      select app_public.cities.id
         into peter_id
         from app_public.cities
         where name = 'Saint-Petersburg'
         limit 1;

      insert into app_public.universities(city_id, short_name, long_name) values
         (peter_id, 'sut', 'Saint-Petersburg university of telecommunications');
   end;
$$;

------------------------------------------------------------------------------------------------------------------------

do $$
   declare
      peter_id uuid;
      sut_id uuid;
      admin_id uuid;
   begin
      select app_public.cities.id
             into peter_id
      from app_public.cities
      where name = 'Saint-Petersburg'
      limit 1;

      select app_public.universities.id
             into sut_id
      from app_public.universities
      where short_name = 'sut'
      limit 1;

      select app_public.users.id
             into admin_id
      from app_public.users
      where is_admin = true
      limit 1;

      insert into app_public.profiles(
         user_id,
         first_name,
         middle_name,
         last_name,
         phone,
         group_number,
         course,
         city_id,
         university_id,
         is_teacher
      ) VALUES
      (
         admin_id,
         'Leo',
         'VS',
         '09',
         '+7-*****',
         'ikpi-52',
         '4',
         peter_id,
         sut_id,
         true
      );
   end;
$$;

------------------------------------------------------------------------------------------------------------------------

insert into app_public.programming_languages(name, alias, version) values
   ('JavaScript', 'js nodejs', 'nodejs 11'),
   ('C++', 'cpp', 'C++17');

insert into app_public.code_editors(name, alias, version) values
   ('Visual Studio Code', 'vscode', '1.33'),
   ('Atom', 'atom', '1.36');

do $$
   declare
    cpp_id uuid;
    js_id uuid;
   begin
      select app_public.programming_languages.id
             into cpp_id
      from app_public.programming_languages
      where name = 'C++'
      limit 1;

      select app_public.programming_languages.id
             into js_id
      from app_public.programming_languages
      where name = 'JavaScript'
      limit 1;

      insert into app_public.compilers(name, alias, code, version, language_id, comment, is_interpreter) VALUES
         ('g++', 'gcc', 'g++ (Debian 6.3.0-18+deb9u1) 6.3.0 20170516', '6.3.0', cpp_id, 'base g++ for debian', false),
         ('nodejs', 'node', 'nodejs v10.15.3', '10.15.3', js_id, 'latest stable version installed by nvm', true);
   end;
$$;

------------------------------------------------------------------------------------------------------------------------

insert into app_public.program_input_type(name, code) values
	('stdin', 'stdin'),
	('file', 'file');

insert into app_public.program_output_type(name, code) values
	('stdout', 'stdout'),
	('file', 'file');

------------------------------------------------------------------------------------------------------------------------

do $$
    declare
        author_id uuid;
        input_id uuid;
        output_id uuid;
    begin
       select app_public.profiles.id
              into author_id
       from app_public.profiles
       where is_teacher = true
       limit 1;

       select app_public.program_input_type.id
              into input_id
       from app_public.program_input_type
       where name = 'stdin'
       limit 1;

       select app_public.program_output_type.id
              into output_id
       from app_public.program_output_type
       where name = 'stdout'
       limit 1;

       insert into app_public.problems(name, input_type_id, output_type_id, limit_time, limit_memory, publication_date, author_id, tester_id, description, input_description, output_description) VALUES
         ('Simple problem', input_id, output_id, 3000, 268435456, now(), author_id, author_id, 'Simple problem, just for start.', 'Three digits', 'One digit'),
         -- https://codeforces.com/problemset/problem/1154/F
         ('Shovels Shop', input_id, output_id, 2000, 268435456, now(), author_id, author_id, 'There are n shovels in the nearby shop. The i-th shovel costs a_i bourles.\nMisha has to buy exactly k shovels. Each shovel can be bought no more than once.\nMisha can buy shovels by several purchases. During one purchase he can choose any subset of remaining (non-bought) shovels and buy this subset.\nThere are also m special offers in the shop. The j-th of them is given as a pair (x_j, y_j), and it means that if Misha buys exactly x_j shovels during one purchase then y_j most cheapest of them are for free (i.e. he will not pay for y_j most cheapest shovels during the current purchase)\nisha can use any offer any (possibly, zero) number of times, but he cannot use more than one offer during one purchase (but he can buy shovels without using any offers).Your task is to calculate the minimum cost of buying k shovels, if Misha buys them optimally.', 'The first line of the input contains three integers n, m and k — the number of shovels in the shop, the number of special offers and the number of shovels Misha has to buy, correspondingly.\nThe second line of the input contains n integers a_1, a_2, ..., a_n, where a_i is the cost of the i-th shovel.\nThe next m lines contain special offers. The j-th of them is given as a pair of integers (x_i, y_i) and means that if Misha buys exactly x_i shovels during some purchase, then he can take y_i most cheapest of them for free.', 'Print one integer — the minimum cost of buying k shovels if Misha buys them optimally'),
         -- https://codeforces.com/problemset/problem/1154/D
         ('Walking Robot', input_id, output_id, 2000, 268435456, null, author_id, author_id, 'There is a robot staying at X=0 on the Ox axis. He has to walk to X=n. You are controlling this robot and controlling how he goes. The robot has a battery and an accumulator with a solar panel.\nThe i-th segment of the path (from X=i-1 to X=i) can be exposed to sunlight or not. The array s denotes which segments are exposed to sunlight: if segment i is exposed, then s_i = 1, otherwise s_i = 0.\nThe robot has one battery of capacity b and one accumulator of capacity a. For each segment, you should choose which type of energy storage robot will use to go to the next point (it can be either battery or accumulator). If the robot goes using the battery, the current charge of the battery is decreased by one (the robot can''t use the battery if its charge is zero). And if the robot goes using the accumulator, the current charge of the accumulator is decreased by one (and the robot also can''t use the accumulator if its charge is zero).\nIf the current segment is exposed to sunlight and the robot goes through it using the battery, the charge of the accumulator increases by one (of course, its charge can''t become higher than it''s maximum capacity).\nIf accumulator is used to pass some segment, its charge decreases by 1 no matter if the segment is exposed or not.\nYou understand that it is not always possible to walk to X=n. You want your robot to go as far as possible. Find the maximum number of segments of distance the robot can pass if you control him optimally.', 'The first line of the input contains three integers n, b, a — the robots destination point, the battery capacity and the accumulator capacity, respectively.\nThe second line of the input contains n integers s_1, s_2, ..., s_n, where s_i is 1 if the i-th segment of distance is exposed to sunlight, and 0 otherwise.', 'Print one integer — the maximum number of segments the robot can pass if you control him optimally');
    end;
$$;

------------------------------------------------------------------------------------------------------------------------

insert into app_public.tags(name) values
   ('data structures'),
   ('implementation'),
   ('sortings'),
   ('greedy'),
   ('math');

do $$
   declare
       imp_id uuid;
       greed_id uuid;
       math_id uuid;

       simple_id uuid;
       shovels_id uuid;
       walking_id uuid;
   begin
      select app_public.tags.id
             into imp_id
      from app_public.tags
      where name = 'implementation'
      limit 1;

      select app_public.tags.id
             into greed_id
      from app_public.tags
      where name = 'greedy'
      limit 1;

      select app_public.tags.id
             into math_id
      from app_public.tags
      where name = 'math'
      limit 1;

      select app_public.problems.id
             into simple_id
      from app_public.problems
      where name = 'Simple problem'
      limit 1;

      select app_public.problems.id
             into shovels_id
      from app_public.problems
      where name = 'Shovels Shop'
      limit 1;

      select app_public.problems.id
             into walking_id
      from app_public.problems
      where name = 'Walking Robot'
      limit 1;

      insert into app_public.problems_tags(problem_id, tag_id) values
         (simple_id, imp_id),
         (shovels_id, greed_id),
         (shovels_id, math_id),
         (walking_id, math_id),
         (walking_id, imp_id),
         (walking_id, greed_id);
   end;
$$;

------------------------------------------------------------------------------------------------------------------------

do $$
   declare
      simple_id uuid;
      shovels_id uuid;
      walking_id uuid;
   begin
      select app_public.problems.id
             into simple_id
      from app_public.problems
      where name = 'Simple problem'
      limit 1;

      select app_public.problems.id
             into shovels_id
      from app_public.problems
      where name = 'Shovels Shop'
      limit 1;

      select app_public.problems.id
             into walking_id
      from app_public.problems
      where name = 'Walking Robot'
      limit 1;

      insert into app_public.tests(index, input, output, is_public, problem_id) VALUES
         (0, '1 1', '0', true, simple_id),
         (1, '2 3', '6', true, simple_id),
         (2, '49 1808', '359087121', true, simple_id),
         (0, '7 4 5\n2 5 4 2 6 3 1\n2 1\n6 5\n2 1\n3 1', '7', true, shovels_id),
         (1, '9 4 8\n6 8 5 1 8 1 1 2 1\n9 2\n8 4\n5 3\n9 7', '17', true, shovels_id),
         (2, '5 1 4\n2 5 7 4 6\n5 4', '17', false, shovels_id),
         (0, '5 2 1\n0 1 0 1 0', '5', true, walking_id),
         (1, '6 2 1\n1 0 0 1 0 1', '3', true, walking_id);
   end;
$$;

------------------------------------------------------------------------------------------------------------------------
