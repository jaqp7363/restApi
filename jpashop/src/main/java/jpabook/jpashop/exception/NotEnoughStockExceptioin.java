package jpabook.jpashop.exception;

public class NotEnoughStockExceptioin extends RuntimeException {
	public NotEnoughStockExceptioin() {
		super();
	}
	
	public NotEnoughStockExceptioin(String msg) {
		super(msg);
	}
	
	public NotEnoughStockExceptioin(String msg, Throwable cus) {
		super(msg, cus);
	}
	
	public NotEnoughStockExceptioin(Throwable cus) {
		super(cus);
	}
}
