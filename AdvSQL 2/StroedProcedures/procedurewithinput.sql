CREATE procedure pnetsalary(@eid int)
as
begin
	declare @bsal int,@ben int,@nsal int

	select @bsal=sal from emp where empid=@eid
	select @ben=sal*isnull(comm,0)/100 from emp where empid=@eid
	set @nsal=@bsal+@ben
	select @eid as EmpID,@bsal as BasicSalary,@ben as Benefits,@nsal NetSalary
end