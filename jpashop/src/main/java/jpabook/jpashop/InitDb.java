package jpabook.jpashop;

import javax.annotation.PostConstruct;
import javax.persistence.EntityManager;

import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import jpabook.jpashop.domain.Address;
import jpabook.jpashop.domain.Delivery;
import jpabook.jpashop.domain.Member;
import jpabook.jpashop.domain.Order;
import jpabook.jpashop.domain.OrderItem;
import jpabook.jpashop.domain.item.Book;
import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class InitDb {

	private final InitService initService;
	
	@PostConstruct
	public void init() {
		initService.dbInit1();
	}
	
	@Component
	@Transactional
	@RequiredArgsConstructor
	static class InitService {
		private final EntityManager em;
		public void dbInit1() {
			Member member = new Member();
			member.setName("userA");
			member.setAddress(new Address("서울시 용산구", "1", "24166"));
			em.persist(member);
			
			Book book = new Book();
			book.setName("JPA1 BOOK");
			book.setPrice(10000);
			book.setStockQuantity(100);
			em.persist(book);
			
			Book book2 = new Book();
			book2.setName("JPA2 BOOK");
			book2.setPrice(10000);
			book2.setStockQuantity(100);
			em.persist(book2);
			
			OrderItem orderItem1 = OrderItem.createOrderItem(book, 10000, 1);
			OrderItem orderItem2 = OrderItem.createOrderItem(book2, 11000, 1);
			
			Delivery delivery = new Delivery();
			delivery.setAddress(member.getAddress());
			Order order = Order.createOrder(member, delivery, orderItem1, orderItem2);
			em.persist(order);
		}
	}
}
