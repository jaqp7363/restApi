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
		
		initService.dbInit2();
	}
	
	@Component
	@Transactional
	@RequiredArgsConstructor
	static class InitService {
		private final EntityManager em;
		public void dbInit1() {
			Member member = createMember("userA","서울시 용산구", "1", "24166");
			em.persist(member);
			
			Book book = createBook("JPA1 BOOK", 10000, 100);
			em.persist(book);
			
			Book book2 = createBook("JPA2 BOOK", 10000, 100);
			em.persist(book2);
			
			OrderItem orderItem1 = OrderItem.createOrderItem(book, 10000, 1);
			OrderItem orderItem2 = OrderItem.createOrderItem(book2, 11000, 1);
			
			Delivery delivery = createDelivery(member);
			Order order = Order.createOrder(member, delivery, orderItem1, orderItem2);
			em.persist(order);
		}
		
		public void dbInit2() {
			Member member = createMember("userB","인천광역시 서구", "1", "24000");
			em.persist(member);
			
			Book book = createBook("Spring1 BOOK", 13000, 100);
			em.persist(book);
			
			Book book2 = createBook("Spring2 BOOK", 10500, 100);
			em.persist(book2);
			
			OrderItem orderItem1 = OrderItem.createOrderItem(book, 13000, 1);
			OrderItem orderItem2 = OrderItem.createOrderItem(book2, 10000, 1);
			
			Delivery delivery = createDelivery(member);
			Order order = Order.createOrder(member, delivery, orderItem1, orderItem2);
			em.persist(order);
		}
		
		private Member createMember(String name, String city, String street,
				String zipcode) {
			Member member = new Member();
			member.setName(name);
			member.setAddress(new Address(city, street, zipcode));
			return member;
		}
		private Book createBook(String name, int price, int stockQuantity) {
			Book book = new Book();
			book.setName(name);
			book.setPrice(price);
			book.setStockQuantity(stockQuantity);
			return book;
		}
		private Delivery createDelivery(Member member) {
			Delivery delivery = new Delivery();
			delivery.setAddress(member.getAddress());
			return delivery;
		}
	}
	
}
