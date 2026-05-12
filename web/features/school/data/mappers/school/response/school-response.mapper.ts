import type { School, SchoolDirectoryList } from "../../../../domain/entities/school";
import type {
  SchoolDirectoryResponseDto,
  SchoolResponseDto,
  SchoolResponseListDto,
} from "../../../schemas/school/response";

export function toSchoolEntity(dto: SchoolResponseDto): School {
  return {
    id: dto.id,
    name: dto.name,
    logoImage: dto.logo_image,
    type: dto.type,
    phone: dto.phone,
    role: dto.role,
  };
}

export function toSchoolEntityList(dtos: SchoolResponseListDto): School[] {
  return dtos.map(toSchoolEntity);
}

export function toSchoolDirectoryEntity(dto: SchoolDirectoryResponseDto): SchoolDirectoryList {
  return {
    schools: dto.schools.map(toSchoolEntity),
    page: dto.page,
    perPage: dto.per_page,
    total: dto.total,
    totalPages: dto.total_pages,
    hasPrev: dto.has_prev,
    hasNext: dto.has_next,
  };
}
