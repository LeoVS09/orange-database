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
insert into app_public.program_input(name) values
	('stdin'),
	('file');

insert into app_public.program_output(name) values
	('stdout'),
	('file');