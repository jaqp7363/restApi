package jpabook.jpashop.domain.item;

import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;

import lombok.Data;

@Entity
@DiscriminatorValue("M")
@Data
public class Movie extends Item {

	private String director;
	private String actor;
}
