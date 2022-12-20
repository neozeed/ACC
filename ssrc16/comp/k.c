int (*func[12])();


test()
{
}
main()
{

	func[4]=test;
	(*func[4])();
	(func[4])();
}
