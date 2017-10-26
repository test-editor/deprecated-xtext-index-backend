package org.testeditor.web.xtext.index.api

import com.fasterxml.jackson.annotation.JsonProperty
import org.hibernate.validator.constraints.Length

public class Saying {
	var long id
	@Length(max=3) var String content

	new() {
	}

	new(long id, String content) {
		this.id = id
		this.content = content
	}

	@JsonProperty
	def getId() {
		return id
	}

	@JsonProperty
	def getContent() {
		return content
	}

}
