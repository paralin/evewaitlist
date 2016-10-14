export interface IService {
  init(): void;
  startup?(): void;
  close?(): void;
}
